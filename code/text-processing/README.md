## Dates and times


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

Regular expressions describe patterns in text using symbols.  You can search for the letter "d" (`pattern = "d"`) or you can search for any digit (0-9) (`pattern = "\\d"`).  Most languages use the same symbols to represent the same features - however, R by default requires two escape characters ("\\") while other languages usually require only one ("\").  Just be aware of that when you go looking up regular expression documentation.

### Pattern matching

* Regex 101 [https://regex101.com/]
  * Test your patterns in real-time and get reminders of what symbols are meant to match what text
* Regex Golf [https://alf.nu/RegexGolf]
* Regex Crossword [https://regexcrossword.com/]

### Capture groups
