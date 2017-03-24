# textAnalysis
This repository is for stuff for processing wikipedia text.  We start with Wikipedia XML dump files.  There are already parsing libraries such as [Parse::MediaWikiDump](http://search.cpan.org/dist/Parse-MediaWikiDump/) for Perl.  There is a nice comment about this library as well as the impossibility of parsing Wikipedia XML at http://stackoverflow.com/questions/2588795/which-module-should-i-use-to-parse-mediawiki-text-into-a-perl-data-structure.

Nonetheless, my goal is to get **a corpus of English sentences for training machine learning algorithms**.  I'm not going to parse for higher level structures, but might later in my learning algorithms.  I really just want a simple text process to get rid of stuff that would make the text too complicated.  Here, I have some notes about the code I've created for processing. I welcome feedback about the code, other issues that could/should be covered.

## Organization
* [Getting Wiki dump files](#getting-wiki-dump-files)
* [Wikipedia XML](#wikipedia-xml)
* [Data File](#data-file) for testing/extraction
* [Cleaning scripts](#cleaning-scripts) for processing the Data File
* [Script comparisons](#script-comparison): tests of speed of different scripts
* [Cleaned Data](#cleaned-data)


## Getting Wiki dump files
You can download dump files from https://dumps.wikimedia.org/. My focus is enwiki, the English wikipedia. File names include
* pages-articles.xml
* abstract.xml
* all-titles

each have the date of the dump included in the name.  If you have a big, fast system, you can use this process on newer files that are available, but as of March 2017, enwiki-20170320-pages-articles.xml.bz2  is 12.9 GB, enwiki-20170320-abstract.xml is 4.8 GB, and enwiki-20170320-all-titles.gz is 220.2 MB.  I went back to the archives to get a smaller file from 2008: `enwiki-20080312-pages-articles.xml.bz2`.  This is a 3.5GB file that when you unzip becomes a 16GB xml file.  It can be downloaded from https://archive.org/download/enwiki-20080312/enwiki-20080312-pages-articles.xml.bz2.

## Wikipedia XML
I'm learning a little about how wikipedia XML works.  Here are some basics:
XML is organized in `<page>`s like this:

```XML
  <page>
    <title>AppliedEthics</title>
    <id>8</id>
    <revision>
      <id>133452279</id>
      <timestamp>2007-05-25T17:12:09Z</timestamp>
      <contributor>
        <username>Gurch</username>
        <id>241822</id>
      </contributor>
      <minor />
      <comment>Revert edit(s) by [[Special:Contributions/Ngaiklin|Ngaiklin]] to last version by [[Special:Contributions/Rory096|Rory096]]</comment>
      <text xml:space="preserve">#REDIRECT [[Applied ethics]] {{R from CamelCase}}</text>
    </revision>
  </page>
```

or this:

```XML
  <page>
    <title>Albedo</title>
    <id>39</id>
    <revision>
      <id>194926362</id>
      <timestamp>2008-02-29T17:13:43Z</timestamp>
      <contributor>
        <ip>92.251.69.133</ip>
      </contributor>
      <comment>/* Black carbon */</comment>
      <text xml:space="preserve">{{otheruses}}
The '''albedo''' of an object is the extent to which it diffusely reflects light from the sun.  It is therefore a more specific form of the term [[reflectivity]].  Albedo is defined as
the ratio of [[diffuse reflection|diffusely reflected]] to incident [[electromagnetic radiation]]. It is a [[Dimensionless number|unitless]] measure indicative of a surface's or body's diffuse [[reflectivity]]. The word is derived from [[Latin]] ''albedo'' &quot;whiteness&quot;, in turn from ''albus'' &quot;white&quot;. The range of possible values is from 0 (dark) to 1 (bright).
[[Image:Albedo-e hg.svg|thumb|Percentage of diffusely reflected sun light in relation to various surface conditions of the earth]]

The albedo is an important concept in [[climatology]] and [[astronomy]]. In climatology it is sometimes expressed as a percentage. Its value depends on the [[frequency]] of radiation considered: unqualified, it usually refers to some appropriate average across the spectrum of [[visible light]]. In general, the albedo depends on the direction and directional distribution of incoming radiation. Exceptions are [[Lambertian]] surfaces, which scatter radiation in all directions in a cosine function, so their albedo does not depend on the incoming distribution. In realistic cases, a [[bidirectional reflectance distribution function]] (BRDF) is required to characterize the scattering properties of a surface accurately, although albedos are a very useful first approximation.C

==Terrestrial albedo==
{| class=&quot;wikitable&quot; style=&quot;float: right;&quot;
|+ Sample albedos
|-
! Surface
! Typical&lt;br /&gt;Albedo
|-
| Fresh asphalt || 0.04&lt;ref name=&quot;heat island&quot;&gt;{{cite web
 | last=Pon | first=Brian | date=June 30, 1999
 | url=http://eetd.lbl.gov/HeatIsland/Pavements/Albedo/
 | title=Pavement Albedo | publisher=Heat Island Group
 | accessdate=2007-08-27
}}&lt;/ref&gt;
|-
| Conifer forest&lt;br /&gt;(Summer) || 0.08&lt;ref&gt;{{cite journal
 | author=Alan K. Betts, John H. Ball
 | title=Albedo over the boreal forest
 | journal=Journal of Geophysical 
 | year=1997
 | volume=102
 | issue=D24
 | pages=28,901–28,910
 | url=http://www.agu.org/pubs/crossref/1997/96JD03876.shtml
 | accessdate=2007-08-27
}}&lt;/ref&gt;
|-
| Worn asphalt || 0.12&lt;ref name=&quot;heat island&quot;/&gt;
|-
| Bare soil || 0.17&lt;ref name=&quot;markvart&quot;&gt;{{cite book
  | author=Tom Markvart, Luis CastaŁżer | year=2003
  | title=Practical Handbook of Photovoltaics: Fundamentals and Applications
  | publisher=Elsevier | id=ISBN 1856173909 }}&lt;/ref&gt;
|-
| Green grass || 0.25&lt;ref name=&quot;markvart&quot;/&gt;
|-
| Desert sand || 0.40&lt;ref&gt;{{cite book 
 | first=G. | last=Tetzlaff | year=1983
 | title=Albedo of the Sahara
 | work=Cologne University Satellite Measurement of Radiation Budget Parameters
 | pages=pp. 60-63 }}&lt;/ref&gt;
|-
| New concrete || 0.55&lt;ref name=&quot;markvart&quot;/&gt;
|-
| Fresh snow || 0.80&amp;ndash;0.90&lt;ref name=&quot;markvart&quot;/&gt;
|}
Albedos of typical materials in visible light range from up to 90% for fresh snow, to about 4% for charcoal, one of the darkest substances. Deeply shadowed cavities can achieve an effective albedo approaching the zero of a [[Black body|blackbody]]. When seen from a distance, the ocean surface has a low albedo, as do most forests, while desert areas have some of the highest albedos among landforms. Most land areas are in an albedo range of .1 to .4.&lt;ref name=&quot;PhysicsWorld&quot;&gt;[http://scienceworld.wolfram.com/physics/Albedo.html Albedo - from Eric Weisstein's World of Physics&lt;!-- Bot generated title --&gt;]&lt;/ref&gt; The average albedo of the [[Earth]] is about 30%.&lt;ref&gt;[http://cat.inist.fr/?aModele=afficheN&amp;cpsidt=1034923 CAT.INIST&lt;!-- Bot generated title --&gt;]&lt;/ref&gt;&lt;ref&gt;[http://www.agu.org/sci_soc/prrl/prrl0113.html Scientists Watch Dark Side of the Moon to Monitor Earth's Climate&lt;!-- Bot generated title --&gt;]&lt;/ref&gt; This is far higher than for the ocean primarily because of the contribution of clouds. 

Human activities have changed the albedo (via forest clearance and farming, for example) of various areas around the globe. However, quantification of this effect is difficult on the global scale.

The classic example of albedo effect is the snow-temperature feedback. If a snow covered area warms and the snow melts, the albedo decreases, more sunlight is absorbed, and the temperature tends to increase. The converse is true: if snow forms, a cooling cycle happens. The intensity of the albedo effect depends on the size of the change in albedo and the amount of [[insolation]]; for this reason it can be potentially very large in the tropics.

The Earth's surface albedo is regularly estimated via [[Earth observation]] satellite sensors such as [[NASA]]'s [[MODIS]] instruments onboard the [[Terra (satellite)|Terra]] and [[Aqua (satellite)|Aqua]] satellites. As the total amount of reflected radiation cannot be directly measured by satellite, a [[mathematical model]] of the BRDF is used to translate a sample set of satellite reflectance measurements into estimates of [[directional-hemispherical reflectance]] and bi-hemispherical reflectance.  

===White-sky and black-sky albedo===
It has been shown that for many applications involving terrestrial albedo, the albedo at a particular [[solar zenith angle]] &lt;math&gt;{\theta_i}&lt;/math&gt; can reasonably be approximated by the proportionate sum of two terms: the directional-hemispherical reflectance at that [[solar zenith angle]], &lt;math&gt;{\bar \alpha(\theta_i)}&lt;/math&gt;, and the bi-hemispherical reflectance, &lt;math&gt;{\bar \bar \alpha}&lt;/math&gt; the proportion concerned being defined as the proportion of diffuse illumination &lt;math&gt;{D}&lt;/math&gt;.&lt;p&gt;

Albedo &lt;math&gt;{\alpha}&lt;/math&gt; can then be given as:&lt;p&gt;

&lt;math&gt;{\alpha}= (1-D) \bar \alpha(\theta_i) + D \bar \bar \alpha.&lt;/math&gt;&lt;p&gt;

[[Directional-hemispherical reflectance]] is sometimes referred to as black-sky albedo and [[bi-hemispherical reflectance]] as white sky albedo. These terms are important because they allow the albedo to be calculated for any given illumination conditions from a knowledge of the intrinsic properties of the surface.

==Astronomical albedo==
The albedo of [[planet]]s, [[natural satellites|satellites]] and [[asteroid]]s can be used to infer much about their properties. The study of albedos, their dependence on wavelength, lighting angle (&quot;phase angle&quot;), and variation in time comprises a major part of the astronomical field of [[photometry (astronomy)|photometry]]. For small and far objects that cannot be resolved by telescopes, much of what we know comes from the study of their albedos. For example, the absolute albedo can indicate the surface ice content of outer solar system objects, the variation of albedo with phase angle gives information about [[regolith]] properties, while unusually high radar albedo is indicative of high metallic content in [[asteroid]]s. 

[[Enceladus (moon)|Enceladus]], a moon of Saturn, has one of the highest known albedos of any body in the solar system, with 99% of EM radiation reflected. Another notable high albedo body is [[Eris (dwarf planet)|Eris]], with an albedo of 86%. Many objects in the outer solar system and [[asteroid belt]] have low albedos down to about 5%. Such a dark surface is thought to be indicative of a primitive and heavily [[space weathering|space weathered]] surface containing some [[organic compound]]s. 

The overall albedo of the [[Moon]] is around 7%, but it is strongly directional and non-Lambertian, displaying also a strong opposition effect.&lt;ref&gt;http://jeff.medkeff.com/astro/lunar/obs_tech/albedo.htm A discussion of Lunar albedos&lt;/ref&gt; While such reflectance properties are different from those of any terrestrial terrains, they are typical of the [[regolith]] surfaces of airless solar system bodies.

Two common albedos that are used in astronomy are the [[geometric albedo]] (measuring brightness when illumination comes from directly behind the observer) and the [[Bond albedo]] (measuring total proportion of electromagnetic energy reflected). Their values can differ significantly, which is a common source of confusion.

In detailed studies, the directional reflectance properties of astronomical bodies are often expressed in terms of the five [[Hapke parameters]] which semi-empirically describe the variation of albedo with [[phase angle (astronomy)|phase angle]], including a characterisation of the [[opposition effect]] of [[regolith]] surfaces.

=== Correlation between astronomical albedo, [[Absolute magnitude#Absolute magnitude for planets (H)|absolute magnitude]] and diameter ===
&lt;math&gt;A =\left ( \frac{1329\times10^{-H/5}}{D} \right ) ^2&lt;/math&gt;,
&lt;br /&gt;&lt;br /&gt;where &lt;math&gt;A&lt;/math&gt; is astronomical albedo, &lt;math&gt;D&lt;/math&gt; is diameter in [[km]].

==Other types of albedo==
[[Single scattering albedo]] - is used to define scattering of electromagnetic waves on small particles. It depends on properties of the material ([[refractive index]]), the size of the particle(s), and the wavelength of the incoming radiation.

==Some examples of terrestrial albedo effects==
===Fairbanks, Alaska===
According to the [[National Climatic Data Center]]'s [[GHCN]] 2 data, which is composed of 30-year smoothed climatic means for thousands of weather stations across the world, the college weather station at [[Fairbanks, Alaska]], is about 3 °C (5.4 °F) warmer than the airport at Fairbanks, partly because of air drainage patterns but also largely because of the lower albedo at the college resulting from a higher concentration of [[spruce]] [[tree]]s and therefore less open snowy ground to reflect the heat back into space.

===The tropics===
Although the albedo-temperature effect is most famous in colder regions of Earth, because more [[snow]] falls there, it is actually much stronger in tropical regions because in the tropics there is consistently more sunlight. When [[Brazil]]ian ranchers cut down dark, tropical [[rainforest]] trees to replace them with even darker soil in order to grow crops, the average temperature of the area increases up to 3 °C (5.4 °F) year-round,&lt;ref&gt;Dickinson, R. E., and P. J. Kennedy, 1992: ''Impacts on regional climate of Amazon deforestation''. Geophys. Res. Lett., '''19''', 1947–1950.&lt;/ref&gt;&lt;ref&gt;[http://web.mit.edu/12.000/www/m2006/final/characterization/abiotic_water.html http://web.mit.edu/12.000/www/m2006/final/characterization/abiotic_water.html]  Project Amazonia: Characterization - Abiotic - Water&lt;/ref&gt; although part of the effect is due to changed evaporation ([[latent heat]] flux).

===Small scale effects===
Albedo works on a smaller scale, too. People who wear dark clothes in the summertime put themselves at a greater risk of [[heatstroke]] than those who wear lighter color clothes.&lt;ref&gt;[http://www.ranknfile-ue.org/h&amp;s0897.html Health and Safety: Be Cool! (8/97)&lt;!-- Bot generated title --&gt;]&lt;/ref&gt;

===Albedo of various terrains===
The albedo of a [[pine]] forest at 45°N in the winter in which the trees cover the land surface completely is only about 9%, among the lowest of any naturally occurring land environment. This is partly due to the color of the pines, and partly due to multiple scattering of sunlight within the trees which lowers the overall reflected light level. Due to light penetration, the ocean's albedo is even lower at about 3.5%, though this depends strongly on the angle of the incident radiation. Dense [[swamp]]land averages between 9% and 14%. [[Deciduous tree]]s average about 13%. A [[grass]]y field usually comes in at about 20%. A barren field will depend on the color of the soil, and can be as low as 5% or as high as 40%, with 15% being about the average for farmland. A [[desert]] or large [[beach]] usually averages around 25% but varies depending on the color of the sand.

===Urban areas===
Urban areas in particular have very unnatural values for albedo because of the many human-built structures which absorb light before the light can reach the surface. In the northern part of the world, cities are relatively dark, and Walker has shown that their average albedo is about 7%, with only a slight increase during the summer. In most tropical countries, cities average around 12%. This is similar to the values found in northern suburban transitional zones. Part of the reason for this is the different natural environment of cities in tropical regions, e.g., there are more very dark trees around; another reason is that portions of the tropics are very poor, and city buildings must be built with different materials. Warmer regions may also choose lighter colored building materials so the structures will remain cooler.

===Trees===
Because trees tend to have a low albedo, removing forests would tend to increase albedo and thereby could produce localized climate cooling. [[Cloud feedback]]s further complicate the issue. In seasonally snow-covered zones, winter albedos of treeless areas are 10% to 50% higher than nearby forested areas because snow does not cover the trees as readily. [[Deciduous trees]] have an albedo value of about 0.15 to 0.18 while [[coniferous trees]] have a value of about 0.09 to 0.15.&lt;ref&gt;{{cite web | url=http://www.ace.mmu.ac.uk/Resources/gcc/1-3-3.html | title=The Climate System | publisher=Manchester Metropolitan University | accessdate=2007-11-11}}&lt;/ref&gt; The difference between deciduous and coniferous is because coniferous trees are darker in general and have cone-shape seeds. The pattern of these seeds trap light energy more than deciduous trees.  

Studies by the [[Hadley Centre]] have investigated the relative (generally warming) effect of albedo change and (cooling) effect of [[carbon sequestration]] on planting forests. They found that new forests in tropical and midlatitude areas tended to cool; new forests in high latitudes (e.g. Siberia) were neutral or perhaps warming.&lt;ref&gt;Betts, R.A. (2000) ''Offset of the potential carbon sink from boreal forestation by decreases in surface albedo'', Nature, Volume 408, Issue 6809, pp. 187-190.&lt;/ref&gt;

===Snow===
Snow albedos can be as high as 90%; this, however, is for the ideal example: fresh deep snow over a featureless landscape. Over [[Antarctica]] they average a little more than 80%.

If a marginally snow-covered area warms, snow tends to melt, lowering the albedo, and hence leading to more snowmelt (the ice-albedo positive [[feedback]]). This is the basis for predictions of enhanced warming in the polar and seasonally snow covered regions as a result of global warming.

===Water===
Water reflects light very differently from typical terrestrial materials. The reflectivity of a water surface is calculated using the [[Fresnel equations]] (see graph).
[[Image:water reflectivity.jpg|thumb|right|250px|Reflectivity of smooth water at 20 C (refractive index=1.333)]]
At the scale of the wavelength of light even wavy water is always smooth so the light is reflected in a [[specular reflection|specular manner]] (not [[Diffuse reflection|diffusely]]). The glint of light off water is a commonplace effect of this. At small angles of incident light, waviness results in reduced reflectivity (from as high as 100%) because of the steepness of the reflectivity-vs.-incident-angle curve and a locally increased average incident angle.&lt;ref&gt;http://lenah.freeshell.org/pp/01-ONW-St.Petersburg/Fresnel.pdf&lt;/ref&gt;

Although the reflectivity of water is very low at high and medium angles of incident light, it increases tremendously at small angles of incident light such as occur on the illuminated side of the earth near the [[terminator (solar)|terminator]] (early morning, late afternoon and near the poles). However, as mentioned above, waviness causes an appreciable reduction. Since the light specularly reflected from water does not usually reach the viewer, water is usually considered to have a very low albedo in spite of its high reflectivity at low angles of incident light. 

Note that White caps on waves look white (and have high albedo) because the water is foamed up (not smooth at the scale of the wavelength of light) so the Fresnel equations do not apply. Fresh ‘black’ ice exhibits Fresnel reflection.

===Clouds===
{{see|Cloud albedo}}

Clouds are another source of albedo that play into the global warming equation. Different types of clouds have different albedo values, theoretically ranging from a minimum of near 0% to a maximum in the high 70s. &quot;On any given day, about half of Earth is covered by clouds, which reflect more sunlight than land and water. Clouds keep Earth cool by reflecting sunlight, but they can also serve as blankets to trap warmth.&quot;&lt;ref&gt;[http://www.livescience.com/environment/060124_earth_albedo.html Baffled Scientists Say Less Sunlight Reaching Earth | LiveScience&lt;!-- Bot generated title --&gt;]&lt;/ref&gt;

Albedo and climate in some areas are already affected by artificial clouds, such as those created by the [[contrail]]s of heavy commercial airliner traffic.&lt;ref&gt;http://facstaff.uww.edu/travisd/pdf/jetcontrailsrecentresearch.pdf&lt;/ref&gt; A study following the burning of the Kuwaiti oil fields by [[Saddam Hussein]] showed that temperatures under the burning oil fires were as much as 10&lt;sup&gt;o&lt;/sup&gt;C colder than temperatures several miles away under clear skies.&lt;ref&gt;[http://adsabs.harvard.edu/abs/1992JGR....9714565C The Kuwait oil fires as seen by Landsat&lt;!-- Bot generated title --&gt;]&lt;/ref&gt;

===Aerosol effects===
[[Particulate|Aerosol]] (very fine particles/droplets in the atmosphere) has two effects, direct and indirect. The direct (albedo) effect is generally to cool the planet; the indirect effect (the particles act as [[Cloud condensation nuclei|CCNs]] and thereby change [[cloud properties]]) is less certain.&lt;ref&gt;[http://www.grida.no/climate/ipcc_tar/wg1/231.htm#671 Climate Change 2001: The Scientific Basis&lt;!-- Bot generated title --&gt;]&lt;/ref&gt;

===Black carbon===
Another albedo-related effect on the climate is from black carbon particles. The size of this effect is difficult to quantify: the [[IPCC]] say that their &quot;estimate of the global mean radiative forcing for BC aerosols from fossil fuels is ... +0.2 W m&lt;sup&gt;-2&lt;/sup&gt; (from +0.1 W m&lt;sup&gt;-2&lt;/sup&gt; in the [[SAR (IPCC)|SAR]]) with a range +0.1 to +0.4 W m...&lt;sup&gt;-2&lt;/sup&gt;&quot;.&lt;ref&gt;[http://www.grida.no/climate/ipcc_tar/wg1/233.htm Climate Change 2001: The Scientific Basis&lt;!-- Bot generated title --&gt;]&lt;/ref&gt;

==See also==
* [[Global dimming]]
* [[Irradiance]]
* [[Insolation]]

==References==
{{reflist}}

==External links==
*[http://www.eoearth.org/article/Albedo Albedo - Encyclopedia of Earth]
*[http://lpdaac.usgs.gov/modis/mod43b1.asp NASA MODIS Terra BRDF/albedo product site] 
*[http://www-modis.bu.edu/brdf/product.html NASA MODIS BRDF/albedo product site] 
*[http://jeff.medkeff.com/astro/lunar/obs_tech/albedo.htm A discussion of Lunar albedos]

{{Global warming}}

[[Category:Electromagnetic radiation]]
[[Category:Climatology]]
[[Category:Climate forcing]]
[[Category:Scattering, absorption and radiative transfer (optics)]]
[[Category:Radiometry]]

[[als:Albedo]]
[[ast:Albedu]]
[[bn:প্রতিফলন অনুপাত]]
[[bs:Albedo]]
[[bg:Албедо]]
[[ca:Albedo]]
[[cs:Albedo]]
[[da:Albedo]]
[[de:Albedo]]
[[et:Albeedo]]
[[el:Λευκαύγεια]]
[[es:Albedo]]
[[eo:Albedo]]
[[eu:Albedo]]
[[fr:Albédo]]
[[gl:Albedo]]
[[ko:반사율]]
[[hr:Albedo]]
[[it:Albedo]]
[[he:אלבדו]]
[[lb:Albedo]]
[[lt:Albedas]]
[[hu:Albedó]]
[[nl:Weerkaatsingsvermogen]]
[[ja:アルベド]]
[[no:Albedo]]
[[nn:Albedo]]
[[nds:Albedo]]
[[pl:Albedo]]
[[pt:Albedo]]
[[ro:Albedo]]
[[ru:Альбедо]]
[[simple:Albedo]]
[[sk:Albedo]]
[[sl:Albedo]]
[[sr:Албедо]]
[[fi:Albedo]]
[[sv:Albedo]]
[[ta:வெண் எகிர்சிதறல்]]
[[tr:Albedo]]
[[uk:Альбедо]]
[[zh:反照率]]</text>
    </revision>
  </page>
```

There is a lot of metadata in the XML tags, but I'm only interested in what is in the `<text>` tags.  There are a lot of the `#REDIRECT` pages which I don't care about for this project.

Note that within the text, there are no tags, but rather **HTML entity codes** like `&gt;` and `&lt;` for `>` and `<`.  These codes create HTML within the text, including tags such as `<blockquote>`, `<gallery>`, `<math>` and so on. This is mixed with a special **Wikimedia markdown** where `'''` indicates `'''`**bold**`'''`, `''` goes around `''`*italics*`''`, `==` goes around a `==`level 2 heading`==`, and `[[` goes around a `[[`_link_`]]`.

If that isn't complicated enough, there are **Templates** indicated by `{{`brackets`}}` which are automatcally translated by the Wikipedia engine to provide standardized mechanisms for presenting particular types of information.  For example, the [convert template](https://en.wikipedia.org/wiki/Template:Convert) takes a number and a pair of units and converts from one to another.  Thus, `{{convert|1|lb|kg}}` displays as `1 pound (0.45 kg)`.  The engine can accomdate a lot of different rules which you should follow the link if you are interested.  Other examples would be: `{{convert|5.56|cm|in|frac=16}}` producing ` 5.56 centimetres (2 3⁄16 in)`or `{{convert|4|acre||disp=preunit|planted |reforested-}}` producing `4 planted acres (1.6 reforested-ha)`.

Other common templates include the [IPA template](https://en.wikipedia.org/wiki/Template:IPA), the [Lang template](https://en.wikipedia.org/wiki/Template:Lang), and the ubiquitous [Infobox](https://en.wikipedia.org/wiki/Help:Infobox).

## Data File
Getting back to our `enwiki-20080312-pages-articles.xml.bz2`data file now, a quick examination shows that it has:
* 16.14 GB filesize
* 259,427,121 lines
* 6,552,490 `</page>` tags; of these, the longest contains 4,380,421 characters.

For development and quick testing, I have created a smaller version using the first 500 pages. [`enwiki-20080312-pages-articles-short.xml`](https://github.com/ultradian/textAnalysis/blob/master/enwiki-20080312-pages-articles-short.xml)  Its filesize is only 7MB.  

## Cleaning scripts
I first created a cleaning script in Perl, [`clean.pl`](https://github.com/ultradian/textAnalysis/blob/master/clean.pl) since that is the kind of thing that Perl was made for.  After I built it, I got to thinking about whether a program in [Julia](http://julialang.org/) would be faster, since speed is one of its goals.  So I created an equivalent script, [`clean.jl`](https://github.com/ultradian/textAnalysis/blob/master/clean.jl).  I then got some [great input](http://stackoverflow.com/questions/42891650/can-you-preallocate-space-for-a-string-in-julia/42972984#42972984) from [Dan Getz](http://stackoverflow.com/users/3580870/dan-getz) and the suggestion I should do some testing.

## Script comparisons

## Cleaned Data
