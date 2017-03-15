#!/usr/bin/perl

# Program to filter Wikipedia XML dumps to "clean" text
# Written by Milton Huang, 2017.  MIT licence

use Time::HiRes qw( gettimeofday tv_interval );
my $t0 = [gettimeofday];

$/="</page>";                     # while record separator
while (<>) {
  /<text(?<text>.+?)<\/text>/s;
  $text = $+{text};
  if ($text !~ /#redirect/i) {
    # remove rest of initial <text> tag
    $text =~ s/.*?>//;
    
    # clean text
    $text =~ s/\{\|.+?\|\}//smg;  # remove tables
    $text =~ s/\[\[Image:.+?\]\]\n//smgi;  # remove images will mess up <!-- comments
    $text =~ s/^\[\[Category:[^\]\n]+?\]\]//smgi;  # remove Categories
    $text =~ s/^\[\[[^\[\]\n]+?\]\]\n//smg;    # remove link lines
    $text =~ s/^\[\[[a-z\-]+?:.+?\]\]//smg;    # remove translation
    

    #templates
    # take first number and first measure of convert
    $text =~ s/\{\{convert\|([^\|]+?)\|(.+?)(?:\}\}|\|[^\}]+?\}\})/$1 $2/sg;
    $text =~ s/\{\{IPA\|(.+?)\}\}/$1/sg;	#IPA
    $text =~ s/\{\{Unicode\|(.+?)\}\}/$1/sg;	#Unicode   
    $text =~ s/\{\{cquote\|(.+?)\}\}/"$1"/sg;	#cquote    
    $text =~ s/\{\{Audio\|[^\|]+?\|(.+?)\}\}/$1/sgi;	#audio title   
    # get rid of rest
    $text =~ s/\{\{([^\{\}]+?)\}\}//sg;	# only unnested
    $text =~ s/\{\{([^\{\}]+?)\}\}//sg;	# another round

    # remove markdown
    $text =~ s/'''([^']+?)'''/$1/sg;  # bold'''
    $text =~ s/''([^']+?)''/$1/sg;  # italic''
    
    # HTML entity codes
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

    $text =~ s/\[\[[^\|\]]+?\|(.+?)\]\]/$1/sg;  # links[[a|a]]
    $text =~ s/\[\[([^\]]+?)\]\]/$1/sg;  # unnamed links[[]]
    $text =~ s/\[http[^\]]+?\]//sgi;  # http links[]

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
    $text =~ s/^;[^\n]*?\n//smg;  # remove : points
   
    # remove quotes
    $text =~ s/''//g;
    $text =~ s/"//g;
    $text =~ s/“//g;
    $text =~ s/”//g;
    
    # remove everything in parens
    $text =~ s/([^\[]*?)\[[^\]]*?\](.*?)/$1 $2/sg;
    $text =~ s/([^\(]*?)\([^\)]*?\)(.*?)/$1 $2/sg;
    
    # get rid of lines ending with:
#    $text =~ s/^[^\n]*?\:\n//smg;  # ending with :
    $text =~ s/^([^\n]*?)\s+?\n/$1\n/smg;  # extra spaces
    $text =~ s/^[^\n]*?[^\.\?!]\n//smg;  # delete not ending with punct
    
    #titles
#    $text =~ s/^=+?[^=]+?=+?\s*?\n//sgm;
       
   
    #multiple \n
    $text =~ s/\s+\,/\,/g;
    $text =~ s/\s+\./\./g;
    $text =~ s/ +/ /g;
    $text =~ s/\n+/\n/g;
    $text =~ s/\n\s/\n/g;    
    print "$text\n";    
  }
}

print("processing time: ");
    $text =~ s/”//g;
printf("%.6f\n", tv_interval ( $t0 ));	# doesn't display if don't printf .6