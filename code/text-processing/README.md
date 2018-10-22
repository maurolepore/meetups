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

## Reading/writing text

### Read in from text file

```
con <- file("https://raw.githubusercontent.com/nmnh-r-users/meetups/master/code/text-processing/arachnids.txt", "r")
arachnids <- readLines(con)
close(con)
```

### Read in from pdf
```
library(pdftools)
saporito <- pdf_text("STEP1_saporito2007_supplementary.pdf")
```

### Write to text file
```
con <- file("newfile.txt", "r")
arachnids <- writeLines("add another line", con, sep = "\n")
close(con)
```

```
cat()
```

## `strsplit()`, `gsub()`, and related functions

## Regular expressions

Regular expressions describe patterns in text using symbols.  You can search for the letter "d" (`pattern = "d"`) or you can search for any digit (0-9) (`pattern = "\\d"`).

### Pattern matching

Escape character drop a character's special meaning and search for the literal character.

Most languages (R, JavaScript, etc.) use the same symbols to represent the same features - however, R by default requires two backslashes to escape a character ("\\\\") while other languages usually require only one ("\\").  Just be aware of that when you go looking up regular expression documentation.


* Regex 101 [https://regex101.com/]
  * Test your patterns in real-time and get reminders of what symbols are meant to match what text
* Regex Golf [https://alf.nu/RegexGolf]
* Regex Crossword (small puzzles with tutorial and themes) [https://regexcrossword.com/]
* Regex Crossword (large puzzle) [https://gregable.com/p/regexp-puzzle.html]

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
