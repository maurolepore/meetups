* Dates and times
* Reading/writing text
* Cleaning and parsing
* Regular expressions (aka regex or regexp)
* Parsing common file formats
* Final thoughts
* Regex resources and practice

# Dates and times

Base R recognizes several classes of objects for dates and times:
* Date - stores date, no time
* POSIXct - stores number of seconds since UNIX epoch
* POSIXlt - stores day, month, year, hour, minute, second, etc. as a list

(https://stackoverflow.com/questions/10699511/difference-between-as-posixct-as-posixlt-and-strptime-for-converting-character-v)

```R
now1 <- date() # returns character
now2 <- Sys.time() # returns POSIX
```

Why use a special date/time classes?
* can recognize order of times, dates, month names
* can apply max, min, diff (durations), round, arithmetic
* smart wrt time zones, daylight savings, etc.

```R
# convert between classes
?as.Date
?as.POSIXct
?as.POSIXlt

# convert character to POSIXlt
# use placeholder characters to define how the character string is formatted
?strptime

now3 <- strptime(now1, format = "%a %b %e %H:%M:%S %Y")
# same as
now3 <- strptime(now1, format = "%c") # "%c" is shortcut for above format

now2 - now1
now2 - now3
```

Some packages exist that provide shortcuts for reformatting dates and times. lubridate ([pdf cheat sheet](https://rawgit.com/rstudio/cheatsheets/master/lubridate.pdf)) is one of these.

```R
library(lubridate)

ymd(20101215)

mdy("4/1/17")

bday <- dmy("14/10/1979")
month(bday)
wday(bday, label = FALSE)
wday(bday, label = TRUE)
```
# Reading/writing text

As perhaps is the theme for today, there are many ways to perform the same task.

### Read in from text file

Using `readLines()`

```R
# read a text file (this one's hosted on github)
arachnids <- readLines("https://raw.githubusercontent.com/nmnh-r-users/meetups/master/code/text-processing/arachnids.txt")
arachnids
```

Using `scan()`

```R
# scan() defaults to separating by any whitespace (" ")
# changed this to separate by line break ("\n")
arachnids <- scan("https://raw.githubusercontent.com/nmnh-r-users/meetups/master/code/text-processing/arachnids.txt", what = character(0), sep = "\n")
```

### Read in from pdf

Using `pdf_text()` in the pdftools package

```R
library(pdftools)

saporito <- pdf_text("https://github.com/nmnh-r-users/meetups/raw/master/code/text-processing/saporito2007_supplementary.pdf")
saporito
```

### Write text to a file

```R
# create a new file
file.create("newfile.txt")
```

Using `writeLines()`
```R
writeLines(c("write the first line", "write the second"), "newfile.txt", sep = "\n")
```

Using `cat()`
```R
cat(c("third", "and fourth lines?"), file = "newfile.txt")
# if append = F, new text overwrites what's already in the file

cat(c("okay third", "and fourth really this time"), file = "newfile.txt", append = T, sep = "\n\n\n")
# include three line breaks between lines of text
```

### Open and close connections

Connections in R can be used to keep a file open for reading bits and pieces or for continuously updating with outputs of the functions you use (or with other things).

(https://stackoverflow.com/questions/30445875/what-exactly-is-a-connection-in-r)

```R
# keep a connection open to a file - can also be url()
# by default, the connection is not immediately opened - you can change this with the argument "open"
con <- file("https://raw.githubusercontent.com/nmnh-r-users/meetups/master/code/text-processing/arachnids.txt")

# open the connection with the function open() with argument open = "r" (for "read") as an alternative to opening the connection via the function file() above
open(con, open = "r")

# do a bunch of stuff
data1 <- readLines(con, n = 10)
data2 <- readLines(con, n = 10)

close(con)

data1
data2
```

# Cleaning and parsing

More often than not, data are messy.  For example, you may be interested in filtering your data frame of specimen data to only specimens collected in the 1950s.  If your data were clean and consistent, you could pull out some logical matches:
* `df$year %in% c(1950:1959)`
* `df$year >= 1950 && df$year <= 1959`

A quick look reveals your column contains everything from:
* 1957
* "1950s"
* "1949-53"
* 51
* "Collected 1958"

... :angry:

Rather than going back to the file and manually cleaning up cells (which may be mistake-prone or force you to eliminate useful data), you can programatically do this in your script. `?grep` covers many functions that can help you do this.

```R
find.waldo <- c("Wilma Odlaw", "Wenda Woof", "Waldo Whitebeard")
```

Take text apart and put text together:
```R
# split elements apart at spaces
indiv <- strsplit(find.waldo, " ")
unlist(indiv)

# combine elements of text
# by default, modifies each element
paste(find.waldo, "PARTY")

# trying to combine elements together?
paste(find.waldo, collapse = " MEET ")
```

Find text:
```R
# find indices of matches
grep("Waldo", find.waldo)

# returns logical vector indicating matches
grepl("Waldo", find.waldo)

# return position and length of match in each element
gregexpr("Waldo", find.waldo)
```

Replace text:
```R
# replace match with another bit of text
gsub("Waldo", "FOUND WALDO", find.waldo)
```

Extract text:
```R
# extract matching text
catch.him <- gregexpr("Waldo", find.waldo)
regmatches(find.waldo, catch.him)
```

Fuzzy match (uses edit distance):
```R
# match via some threshold on how many insertions, deletions, and substitutions are allowed (see ?agrep)
agrep("Woldo", find.waldo)
```


```R
# clean up text from the pdf from before (originally each page is one element in a vector)
# "\n" is the symbol for a line break
strsplit(saporito, split = "\n")
```


```R
verts <- read.csv("https://raw.githubusercontent.com/nmnh-r-users/meetups/master/code/text-processing/vertebrates.csv", stringsAsFactors = F)

# get rid of "Late" in $early_interval

# programmatically clean $county - McCone County vs McCone

# split $accepted_name into new $genus and $species columns

# split $diet so that you only keep the first assigned category
```

What if there are a number of words you need matched?  What if the text isn't well defined (e.g., not bordered nicely by spaces)?

# Regular expressions (aka regex or regexp)

The same way "%Y" and "%y" are different ways (placeholders) of representing years in date/time objects, regular expressions describe patterns in text using symbols.  You can search for the literal letter "d" (`pattern = "d"`) or you can search for any digit (0-9) (`pattern = "\\d"`).  Nearly all of the functions mentioned above for cleaning and parsing can take a regex pattern.

### Pattern matching

Instead of using a literal pattern (like "Waldo"), you can use a pattern of symbols.

Examples of useful regex symbols:
* `.` = any character
* `+` = one or more of the preceding expression (e.g., `g+` matches one or more of the letter "g")
* `k{3,5}` = the letter "k" at least three times ("kkk") but no more than 5 times ("kkkkk")
* `(chocolate|vanilla)` = either the word "chocolate" or the word "vanilla"
* `[HAND]` = only the characters "H", "A", "N", or "D" (no other characters)
* `[^HAND]` = any characters EXCEPT "H", "A", "N", or "D"
* `e?` = maybe the letter "e" is there, maybe not

Many examples can be found at `?regex`, but more extensive documentation is a quick Google search away.

> Would each of the following strings match the pattern `(chocolate|vanilla){2,}`?  Why or why not?  
> A. "I bought a tub of chocolate ice cream."  
> B. "cinnamon chocolate chocolate"  
> C. "chocolatevanillachocolate"  

Note: Escape characters drop a character's first meaning. "\\\\d" for example drops the meaning of "d" (literal letter) and searches for a digit.  "\\\\." meanwhile drops the first meaning of "." (any character) and searches for a literal period.

Most languages (R, JavaScript, etc.) use the same symbols to represent the same features - however, R by default requires two backslashes to escape a character ("\\\\") while other languages usually require only one ("\\").  R escapes the special meaning of the backslash, so that it can be read as a backslash in the pattern, to be interpreted with its special meaning in the function.  Just be aware of that when you go looking up regular expression documentation.

Let's go back to one of the tasks for the vertebrates table - isolate the **first word**, whatever it may be, of the `$diet` column using:

```R
strsplit()


gsub()


grepexpr()
# and
regmatches()
```

Regular expressions are particularly powerful ways of mining data.  For the text file "arachnids.txt", collect species names, countries, and locality coordinates.

```R
# read in file
con <- file("https://raw.githubusercontent.com/nmnh-r-users/meetups/master/code/text-processing/arachnids.txt", "r")
arachnids <- readLines(con)
close(con)

# mark the first line of each "entry"
first <- grepl("comb. nov.", arachnids)
# or
first <- c(1, which(arachnids == "") + 1)
arachnids[first] <- paste(arachnids[first], "FIRSTLINE")
first <- grepl("FIRSTLINE", arachnids)

# add "\n" to the empty lines
arachnids[arachnids == ""] <- "\n"
# add "\n" to the ends of the first lines
arachnids[first] <- paste0(arachnids[first], "\n")

# concatenate into one big long string
arachnids <- paste(arachnids, collapse = "")
# split into separate elements by the "\n"
arachnids <- strsplit(arachnids, "\n")[[1]]

# everything done so far was just to get the descriptions on one line,
# separate from the line that contains species names,
# in a way that is trackable (we know the locations of names and desciptions)

arachnids

# update our record of the first line of each entry
first <- grepl("comb. nov.", arachnids)
# or
first <- grepl("FIRSTLINE", arachnids)
# what lines are our descriptions on
desc <- which(first) + 1
```

Now for the more flexible patterns:

```R
# for each first line, isolate species name
# match a space ("\\s") followed by an open parenthesis ("\\(") followed by any character (".") one or more times ("+")
species <- gsub("\\s\\(.+", "", arachnids[first])

# for each description, isolate country
countries <- gsub(".+\\s([A-Z]{2,})[.:].+", "\\1", arachnids[desc])

# for each description, isolate any coordinates given
# match literal parentheses ("\\(  \\)") that have within them a number, decimal, comma, space, or negative ("[0-9., -]") one or more times ("+")
coords <- gregexpr("\\([0-9., -]+\\)", arachnids[desc])
coords <- regmatches(arachnids[desc], coords)
coords <- lapply(coords, function(x){
  x <- gsub("[()]", "", x)
  x <- strsplit(x, ", ")
  do.call("rbind", x)
})
```

### Capturing groups

Capturing groups are matched text that you can refer back to using `\\1`, `\\2`, etc.

Capturing groups are denoted within the pattern using parentheses - everything that is matched using the expression in those parentheses can be called back up.  Parentheses can be nested, creating multiple capturing groups that are numbered outside in, left to right.

```R
a <- "first second third"
gsub("first second", "MATCHED", a)
gsub("(first|second)", "MATCHED", a)
gsub("(first) (second)", "\\2 \\1", a)
gsub("((first) (second))", "\\2 \\1", a)
```

> We want to make a plot of `verts` that will show the species name.  Create a new column (`$label`) that contains the abbreviated genus with species name (e.g., *M. musculus*) for space saving.
> 
> ```R
> verts
> 
> 
> ```


# Parsing common file formats

All this being said, many packages exist for fast conversion of common file formats to lists or data frames.  What they're really doing is what we were just doing above - read in lines, split and reorganize by recognizable characters, put things back together.  Even functions like `read.csv()` are pattern matching commas and line breaks to organize columns and rows, respectively.  Examples of packages that exist include:

JSON
```R
library(jsonlite)
library(rjson)

json.file <- "http://api.worldbank.org/country?per_page=10&region=OED&lendingtype=LNX&format=json"

# what JSON format looks like
readLines(json.file)

jsonlite::fromJSON(json.file, flatten = TRUE)
rjson::fromJSON(paste(readLines(json.file), collapse = ""))
```

XML (and HTML)
```R
library(XML)

xml.file <- "http://api.worldbank.org/country?per_page=10&region=OED&lendingtype=LNX"

xml.text <- xmlParse(xml.file)
xmlToList(xml.text)

# htmlParse() will supposedly work for html files
```

# Final thoughts

* Regular expressions are all about considering edge cases.
* **ALWAYS** check to make sure things are working.  While some mistakes in the pattern are easy to spot (you'll see blanks where it there should be text or long strings of text where there should be one word), spot check (or even check every line!) against the text, making sure you've grabbed what you wanted to grab.
* *If the pattern fits...*  There is no one right approach to extracting the text you want.  Different functions get you there in different ways, patterns are super flexible.  So don't stress about it - if you get it to work, then it works!


# Regex resources and practice

* Regex 101 [https://regex101.com/]
  * Test your patterns in real-time and get reminders of what symbols are meant to match what text
* Regex Golf [https://alf.nu/RegexGolf]
* Regex Crossword (small puzzles with tutorial and themes) [https://regexcrossword.com/]
* Regex Crossword (large puzzle) [https://gregable.com/p/regexp-puzzle.html]
