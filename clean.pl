#!/usr/bin/perl

# Program to filter Wikipedia XML dumps to "clean" text
# Written by Milton Huang, 2017.  MIT licence

use Time::HiRes qw( gettimeofday tv_interval );
my $t0 = [gettimeofday];

$/="</page>";                     # while record separator
while (<>) {
  # process only inside text tag
  /<text(?<text>.+?)<\/text>/s;
  $text = $+{text};
  if ($text !~ /#redirect/i) {
    # remove rest of initial <text> tag
    $text =~ s/.*?>//;
    
    # clean text
    $text =~ s/\{\|.+?\|\}//sg;  # remove tables
    $text =~ s/^\[\[Category:[^\]\n]+?\]\]//smgi;  # remove Categories
    $text =~ s/^\[\[[^\[\]\n]+?\]\]\n//smg;    # remove link lines
    $text =~ s/^\[\[[a-z\-]+?:.+?\]\]\n//smg;    # remove translation
    $text =~ s/^\[\[[a-z\-]+?:.+?\]\]\z//smg;    # some end with <text>
    # really this needs to be done recursively to manage embedded links
    $text =~ s/\[\[Image:[^\[]+?\]\]//sgi;  # remove images without embedded
    $text =~ s/\[\[Image:[^\[]+?\[\[.+?\]\][^\[]+?\]\]//sgi;  # remove images with embedded
    
    $text =~ s/\[\[[^\|\[\]]+?\|(.+?)\]\]/$1/sg;  # links[[a|a]] without embedded
    $text =~ s/\[\[([^\[\]]+?)\]\]/$1/sg;  # unnamed links[[]] without embedded
    $text =~ s/\[http[^ ]+?([^\]])*?\]/$1/sgi;  # http links[]


    ## templates
    $text =~ s/\{\{cite[^\{]+?\}\}//sgi;	#remove cite
    # take first number and first measure of convert
    $text =~ s/\{\{convert\|([^\|]+?)\|(.+?)(?:\}\}|\|[^\}]+?\}\})/$1 $2/sgi;
    $text =~ s/\{\{IPA\|(.+?)\}\}/$1/sgi;	#IPA
    $text =~ s/\{\{nihongo\|([^\|]+?)\|[^\}]+?\}\}/$1/sgi;	#nihongo
    $text =~ s/\{\{lang\|[^\|]+?\|([^\}]+?)\}\}/$1/sgi;	#lang
    $text =~ s/\{\{Unicode\|(.+?)\}\}/$1/sgi;	#Unicode   
    $text =~ s/\{\{Audio\|[^\|]+?\|(.+?)\}\}/$1/sgi;	#audio title   
    $text =~ s/\{\{cquote\|([^\{]+?)\}\}/"$1"/sgi;	#cquote without embedded
    # get rid of rest
    $text =~ s/\{\{([^\{\}]+?)\}\}//sg;	# only unnested
    $text =~ s/\{\{([^\{\}]+?)\}\}//sg;	# another round

    # remove markdown
    $text =~ s/'''([^']+?)'''/$1/sg;  # bold'''
    $text =~ s/''([^']+?)''/$1/sg;  # italic''
    
    ## HTML entity codes
    # creates HTML tags including <!-- comments
    $text =~ s/&amp;/&/gi;
    $text =~ s/&quot;/"/gi;
    $text =~ s/&gt;/>/gi;
    $text =~ s/&lt;/</gi;
    $text =~ s/&nbsp;/ /gi;
    $text =~ s/&ndash;/–/gi;
    $text =~ s/&mdash;/—/gi;
    $text =~ s/&#91;/[/g;
    $text =~ s/&#93;/]/g;
    $text =~ s/&#40;/(/g;
    $text =~ s/&#41;/)/g;
   
    #html
    $text =~ s/<!--.+?-->//sg;  # remove comments
    $text =~ s/<small>([^\<]*?)<\/small>/$1/gi;
    $text =~ s/<s>([^\<]*?)<\/s>/$1/gi;	# unclear if delete or keep
    $text =~ s/<sup>2<\/sup>/²/gi;
    $text =~ s/<sup>3<\/sup>/³/gi;
    $text =~ s/<sup>([^\<]+?)<\/sup>/$1/gi;
    $text =~ s/<sub>([^\<]+?)<\/sub>/$1/gi;

    # just get rid of math for now
    $text =~ s/<math[^<]*?<\/math>//gi;	#fail if <tag> inside
    $text =~ s/<br[^<>]*?>//gi;
    $text =~ s/<\/br[^<>]*?>//gi;
    $text =~ s/<blockquote>//gi;
    $text =~ s/<\/blockquote>//gi;
    $text =~ s/<span[^\>]*?\>([^\<]+?)<\/span>/$1/sgi;
    $text =~ s/<i>([^<]*?)<\/i>/$1/gi;	#fail if <tag> inside
    $text =~ s/<gallery[^<]*?<\/gallery>//gi;	#fail if <tag> inside
    $text =~ s/<gallery\/>//gi;
    $text =~ s/^<table.+?<\/table>//smgi;
    $text =~ s/^<div.+?<\/div>//smgi;
    # remove references
    $text =~ s/<ref[^\/]*?\/>//sgi;	# get <ref /> singles
    $text =~ s/<ref.*?>.*?<\/ref>//sgi;	# get <ref></ref> pairs

    # delete rest of html tags
    $text =~ s/<nowiki>//gi;
    $text =~ s/<\/nowiki>//gi;
    $text =~ s/<u>//gi;
    $text =~ s/<\/u>//gi;
    $text =~ s/<[^>]*?>//sgi;
    
    # remove bullet points avoid clipping matched {{ }}
    $text =~ s/^\*[^\n]*?\n//smg;  # remove bullet points
    $text =~ s/^#[^\n]*?\n//smg;  # remove numbered points
    $text =~ s/^:[^\n]*?\n//smg;  # remove : points
    $text =~ s/^;[^\n]*?\n//smg;  # remove ; points
    $text =~ s/^|[^\n]*?\n//smg;  # remove infobox lines that didn't get taken out before
   
    # remove quotes
    $text =~ s/''//g;
    $text =~ s/"//g;
    $text =~ s/“//g;
    $text =~ s/”//g;
    
    # remove everything in parens
    $text =~ s/([^\[]*?)\[[^\]]*?\](.*?)/$1 $2/sg;
    $text =~ s/([^\(]*?)\([^\)]*?\)(.*?)/$1 $2/sg;
    
    # beginning and endings
#    $text =~ s/^[^\n]*?\:\n//smg;  # ending with :
    $text =~ s/^\s+?([^\n]*?\n)/$1/smg;  # chomp initial whitespace
    $text =~ s/^([^\n]*?\n)\s+?\n/$1/smg;  # chomp terminal whitespace
    $text =~ s/^([^\n]*?)\s+?\n/$1\n/smg;  # extra spaces before \n
    $text =~ s/^[^\n]*?[^\.\?!]\n//smg;  # delete not ending with punct
    
    #titles (covered by not ending in punct)
#    $text =~ s/^=+?[^=]+?=+?\s*?\n//sgm;
       
   
    #multiple \n
    $text =~ s/\n\s/\n/g;    
    $text =~ s/\n+/\n/g;

    # multiple spaces
    $text =~ s/\s+\,/\,/g;
    $text =~ s/\s+\./\./g;
    $text =~ s/ +/ /g;    
    $text =~ s/([\.\?,!])\s*[\.\?,!]/$1/g;    
    print "$text\n";    
  }
}

print("processing time: ");
    $text =~ s/”//g;
printf("%.6f\n", tv_interval ( $t0 ));	# doesn't display if don't printf .6