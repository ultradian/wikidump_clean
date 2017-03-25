function maxsize(fn::AbstractString)
    fs = open(fn,"r")
    c = 0
    longest = 0
    while !eof(fs)
	p = readuntil(fs,"</page>\n")
	c += 1
	longest = length(p) > longest ? length(p) : longest
    end
    close(fs)
    println("count:",c," maxlength:",longest)
    return c, longest
end

"""
    pagecrop(fn::AbstractString, npages::Integer)
    
Takes Wikipedia XML file named fn, and shortens it looking for `</page>` tags
Shortens to `npages` number of pages.
Saves output to new file with same name, but trailing `.xml` changed to `-short.xml`
"""
function pagecrop(fn,npages)
    is = open(fn,"r")
    os = open(replace(fn, r"(\.\w+?)\z", s"-short\1"), "w")
    for i = 1:npages
	text = readuntil(is,"</page>\n")
	if eof(is)
	    warn("reached eof for ",fn)
	    close(os)
	    close(is)
	    return
	end
	print(os, text)
    end
    close(os)
    close(is)
end

"""
    clean(fn::AbstractString)
    
Cleans Wikipedia XML file named `fn`, using regex.  
Saves output to new file with same name, but trailing `.xml` removed
and replaced with `-clean.txt`
"""
function clean(fn::AbstractString)
    fs = open(fn,"r")
    os = open(replace(fn, r"(\.\w+?)\z", s"-clean.txt"), "w")
    while !eof(fs)
	text = readuntil(fs,"</page>\n")
	# process only inside text tag
	text = match(r"<text.+?<\/text>"s,text).match
	if ! ismatch(r"#redirect"i, text)
	    # remove rest of initial <text> tag
	    text = replace(text, r".*?>", "")
	    
	    # clean text
	    text = replace(text, r"\{\|.+?\|\}"s, "")	# remove tables
	    text = replace(text, r"^\[\[Category:[^\]\n]+?\]\]"sim, "")	# remove Categories
	    text = replace(text, r"^\[\[Category:[^\]\n]+?\]\]\z"sim, "")	# some end with </text>
	    text = replace(text, r"^\[\[[^\[\]\n]+?\]\]\n"sm, "")	# remove link lines
	    text = replace(text, r"^\[\[[a-z\-]+?:.+?\]\]\n"sm, "")	# remove translation
	    text = replace(text, r"^\[\[[a-z\-]+?:.+?\]\]\z"sm, "")	# some end with <text>

	    text = replace(text, r"\[http\S+?\]"si, "")	# http links[] without anchor
	    text = replace(text, r"\[http\S+?\s+?(.*?)\]"si, s"\1")	# http links[]
	    
	    # is there a better way to manage embedded links?
	    # would still over reach with .+?\]\]
	    text = replace(text, r"\[\[Image:[^\[]+?\]\]"si, "")	# remove images without embedded
	    
	    text = replace(text, r"\[\[[^\|\[]+?\|([^\[]+?)\]\]"s, s"\1")	# links[[a|a]]] without embedded
	    text = replace(text, r"\[\[([^\|\[]+?)\]\]"s, s"\1")	# unnamed links[[]]] without embedded
	    text = replace(text, r"\[\[Image:[^\[]+?\]\]"si, "")	# remove images after embedded removed

	    ## templates
	    # take first number and first measure of convert
	    text = replace(text, r"\{\{convert\|([^\|]+?)\|(.+?)(?:\}\}|\|[^\}]+?\}\})"si, s"\1 \2")
	    text = replace(text, r"\{\{IPA\|(.+?)\}\}"si, s"\1")
	    text = replace(text, r"\{\{nihongo\|([^\|]+?)\|[^\}]+?\}\}"si, s"\1")
	    text = replace(text, r"\{\{lang\|[^\|]+?\|([^\}]+?)\}\}"si, s"\1")
	    text = replace(text, r"\{\{Unicode\|(.+?)\}\}"si, s"\1")
	    text = replace(text, r"\{\{Audio\|[^\|]+?\|(.+?)\}\}"si, s"\1")
	    text = replace(text, r"\{\{cquote\|(.+?)\}\}"si, s"\1")	#cquote ignore embedded
	    # get rid of rest
	    # includes wikiquote, wikisource, cite, date, infobox, main
	    text = replace(text, r"\{\{([^\{\}]+?)\}\}"s, "")	# only unnested
	    text = replace(text, r"\{\{([^\{\}]+?)\}\}"s, "")	# another round

	    # remove markdown
	    text = replace(text, r"'''([^']+?)'''"s, s"\1")	# bold'''
	    text = replace(text, r"''([^']+?)''"s, s"\1")	# italic''
	    
	    ## HTML entity codes
	    # creates HTML tags including <!-- comments
	    text = replace(text, r"&amp;"i, "&")
	    text = replace(text, r"&quot;"i, "\"")
	    text = replace(text, r"&gt;"i, ">")
	    text = replace(text, r"&lt;"i, "<")
	    text = replace(text, r"&nbsp;"i, " ")
	    text = replace(text, r"&ndash;"i, "-")
	    text = replace(text, r"&mdash;"i, "-")
	    text = replace(text, r"&#91;", "[")
	    text = replace(text, r"&#93;", "]")
	    text = replace(text, r"&#40;", "(")
	    text = replace(text, r"&#41;", ")")
	    
	    #html
	    text = replace(text, r"<!--.+?-->"s, "")	# remove comments
	    text = replace(text, r"<small>([^\<]*?)<\/small>"i, s"\1")
	    text = replace(text, r"<s>([^\<]*?)<\/s>"i, s"\1")	# unclear if delete or keep
	    text = replace(text, r"<sup>2<\/sup>"i, "²")
	    text = replace(text, r"<sup>3<\/sup>"i, "³")
	    text = replace(text, r"<sup>([^\<]+?)<\/sup>"i, s"\1")
	    text = replace(text, r"<sub>([^\<]+?)<\/sub>"i, s"\1")
	    
	    # get rid of math for now
	    text = replace(text, r"<math[^<]*?<\/math>"i, "")	#fail if <tag> inside
	    text = replace(text, r"<br[^<>]*?>"i, "")
	    text = replace(text, r"<\/br[^<>]*?>"i, "")
	    text = replace(text, r"<blockquote>"i, "")
	    text = replace(text, r"<\/blockquote>"i, "")
	    text = replace(text, r"<span[^\>]*?\>([^\<]+?)<\/span>"si, s"\1")
	    text = replace(text, r"<i>([^<]*?)<\/i>"i, s"\1")	#fail if <tag> inside
	    text = replace(text, r"<gallery[^<]*?<\/gallery>"i, "")	#fail if <tag> inside
	    text = replace(text, r"<gallery\/>"i, "")
	    text = replace(text, r"^<table.+?<\/table>"smi, "")
	    text = replace(text, r"^<div.+?<\/div>"smi, "")
	    # remove references
	    text = replace(text, r"<ref[^\/]*?\/>"si, "")	# get <ref /> singles
	    text = replace(text, r"<ref.*?>.*?<\/ref>"si, "")	# get <ref></ref> pairs

	    # delete rest of html tags
	    text = replace(text, r"<nowiki>"i, "")
	    text = replace(text, r"<\/nowiki>"i, "")
	    text = replace(text, r"<u>"i, "")
	    text = replace(text, r"<\/u>"i, "")
	    text = replace(text, r"<[^>]*?>"si, "")
	    
	   # remove bullet points avoid clipping matched {{ }}
	    text = replace(text, r"^\*[^\n]*?\n"sm, "")	# remove bullet points
	    text = replace(text, r"^#[^\n]*?\n"sm, "")	# remove numbered points
	    text = replace(text, r"^:[^\n]*?\n"sm, "")	# remove : points
	    text = replace(text, r"^;[^\n]*?\n"sm, "")	# remove ; points
	    text = replace(text, r"^\|[^\n]*?\n"sm, "")	# remove infobox lines that remain
	    
	    # uniform quotes
	    text = replace(text, r"''", "\"")
	    text = replace(text, r"“", "\"")
	    text = replace(text, r"”", "\"")
	    
	    # beginning and endings
	    text = replace(text, r"^\s+?([^\n]*?\n)"sm, s"\1")	# chomp initial whitespace
	    text = replace(text, r"^([^\n]*?\n)\s+?\n"sm, s"\1")	# chomp terminal whitespace
	    text = replace(text, r"^([^\n]*?)\s+?\n"sm, s"\1" * "\n")	# extra spaces before \n
	    text = replace(text, r"^[^\n]*?[^\.\?!]\n"sm, "")	# delete not ending with punct
	    
	    # multiple \n
	    text = replace(text, r"\n\s", "\n")
	    text = replace(text, r"\n+", "\n")

	    # multiple spaces
	    text = replace(text, r"\s+\,", ",")
	    text = replace(text, r"\s+\.", ".")
	    text = replace(text, r" +", " ")
	    text = replace(text, r"([\.\?,!])\s*[\.\?,!]", s"\1")
	    print(os, text, "\n")
	end
    end
    close(os)
    close(fs)
end