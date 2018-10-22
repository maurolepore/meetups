## Dates and times

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

Some packages exist that provide shortcuts for reformatting dates and times. [lubridate](https://rawgit.com/rstudio/cheatsheets/master/lubridate.pdf) is one of these.

```R
library(lubridate)

ymd(20101215)

mdy("4/1/17")

bday <- dmy("14/10/1979")
month(bday)
wday(bday, label = FALSE)
wday(bday, label = TRUE)
```

## Cleaning and parsing

For example, you may be interested in filtering your data frame of specimen data to only specimens collected in the 1950s.  If your data were clean and consistent, you could pull out some logical matches:
* df$year %in% c(1950:1959)
* df$year >= 1950 && df$year <= 1959

A quick look reveals your column contains everything from:
* 1957
* "1950s"
* "1949-53"
* 51
* "Collected 1958"

... :angry:

`strsplit()`, `gsub()`, and related functions

```R
chordata <- read.csv("https://raw.githubusercontent.com/nmnh-r-users/meetups/master/code/text-processing/vertebrates.csv", stringsAsFactors = F)

# split $diet so that you only keep the first assigned category

# programmatically clean $county - McCone County vs McCone

# split $accepted_name into genus and species columns

# get rid of "Late" in $early_interval

# split $taxon_environment into actual categories (brackish, freshwater, terrestrial)
```

```R
# quickly format contraint tree and write to file

```

## Reading/writing text

### Read in from text file

```
# open connection to any file (this one's hosted on github)
con <- file("https://raw.githubusercontent.com/nmnh-r-users/meetups/master/code/text-processing/arachnids.txt", "r")
arachnids <- readLines(con)
close(con)
```

### Read in from pdf

```
library(pdftools)
saporito <- pdf_text("https://github.com/nmnh-r-users/meetups/raw/master/code/text-processing/saporito2007_supplementary.pdf")
```

### Write text to a file

```
file.create("newfile.txt")
con <- file("newfile.txt", "w")
writeLines(c("write the first line", "write the second"), con, sep = "\n")
close(con)
```

```R
cat(c("third", "and fourth lines?"), file = "newfile.txt")
cat(c("okay third", "and fourth really this time"), file = "newfile.txt", append = T, sep = "\n\n\n")
```





## Regular expressions (aka regex or regexp)

The same way "%Y" and "%y" are different ways (placeholders) of representing years in date/time objects, regular expressions describe patterns in text using symbols.  You can search for the literal letter "d" (`pattern = "d"`) or you can search for any digit (0-9) (`pattern = "\\d"`).

### Pattern matching

Examples of useful regex symbols:
* `.` = any character
* `+` = one or more of the preceding expression
* `f{3,5}` = the letter "f" at least two times ("ff") but no more than 5 times ("fffff")
* `(chocolate|vanilla)` = either the word "chocolate" or the word "vanilla"
* `[HAND]` = only the characters "H", "A", "N", or "D" (no other characters)
* `[^HAND]` = any characters EXCEPT "H", "A", "N", or "D"

Would each of the following strings match the pattern `(chocolate|vanilla){2,}`?  Why or why not?
A. "I bought a tub of chocolate ice cream."
B. "chocolatevanillachocolate"
C. "cinnamon chocolate chocolate"

Escape character drop a character's special meaning and search for the literal character.

Most languages (R, JavaScript, etc.) use the same symbols to represent the same features - however, R by default requires two backslashes to escape a character ("\\\\") while other languages usually require only one ("\\").  R escapes the special meaning of the backslash, so that it can be read as a backslash in the pattern, to be interpreted with its special meaning in the function.  Just be aware of that when you go looking up regular expression documentation.

* Regex 101 [https://regex101.com/]
  * Test your patterns in real-time and get reminders of what symbols are meant to match what text
* Regex Golf [https://alf.nu/RegexGolf]
* Regex Crossword (small puzzles with tutorial and themes) [https://regexcrossword.com/]
* Regex Crossword (large puzzle) [https://gregable.com/p/regexp-puzzle.html]

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
# separate from the line that contains species names
# in a way that is trackable (we know the locations of names and desciptions)
arachnids
```

```R
# update our record of the first line of each entry
first <- grepl("comb. nov.", arachnids)
# or
first <- grepl("FIRSTLINE", arachnids)
# what lines are our descriptions on
desc <- which(first) + 1

# for each first line, isolate species name
species <- gsub("\\s\\(.+", "", arachnids[first])

# for each description, isolate country
countries <- gsub(".+\\s([A-Z]{2,})[.:].+", "\\1", arachnids[desc])

# for each description, isolate any coordinates given
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

Capturing groups are denoted within the pattern using parentheses - everything that is matched using the expression in those parentheses can be called back up.  Parentheses can be nested, creating multiple capturing groups that are number outside in, left to right.

```
a <- "first second third"
gsub("first second", "MATCHED", a)
gsub("(first|second)", "MATCHED", a)
gsub("(first) (second)", "\\2 \\1", a)
gsub("((first) (second))", "\\2 \\1", a)
```

Let's go back to one of the tasks for the vertebrates table - isolate the first word

gsub()
grepexpr() plus regmatches()
strsplit()




