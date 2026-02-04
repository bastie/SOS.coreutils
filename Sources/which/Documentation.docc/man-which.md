# ``which``

Print the path of the program.

## **SYNOPSIS**

    which [-as] [program]

## **DESCRIPTION**

The **which** utility prints the path of the executable programs.

These options are available:

-a      List all instances of program found, instead of the default (first)

-s      Quiet mode, returns 0 if all of the programs are found, or non-zero if one ore more not found.

## **EXIT STATUS**

Returns 0 if all programs are found and executable, returns 2 if no programs are found or executable and returns 1 if some programs are found and executable but not all.

## **EXAMPLES**

```bash
$ which ls
/bin/ls
…
```

## **NOTE**

> Important: Unlike of default implementations, shell buildin function can implemented different.

## **AUTHORS**

**Implementation:** Sebastian Ritter 

**Documentation:** Sebastian Ritter
