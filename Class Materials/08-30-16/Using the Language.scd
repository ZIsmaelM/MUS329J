s = Server.local.boot;

o = Server.local.options;
o.device = "ASIO : ASIO FW-1884";
o.device;

/* Data Types in SuperCollider */

/***** Literals  - Browse the manual for Language/Literals *****/

//Integers (whole numbers with no fractional part)
5
-5
8192
100.class //this is not a decimal digit!

//Floats (number.number - i.e., must have decimal digits on both sides of the dot)
0.5
3.14159
-90.5
100.0.class //digits on both sides of the decimal point allows this

5.  //This will throw an error, because no trailing digit
.5  // ditto, because no leading digit

/* Some things you can do with Integers and Floats, besides simple arithmetic */

5.25.squared
7.reciprocal
15.neg  //flip the sign of this number
11.isPrime //True if this is a prime number, otherwise false
113.indexOfPrime //this is the 29th prime number
112.prevPrime
114.nextPrime
20.even     //Test if even or odd
21.odd
65536.isPowerOfTwo //True or false
65537.nextPowerOfTwo
10.factorial //computes 10 factorial
150.factors //returns prime factors as an array
13.dup(10) //returns an array of 10 13s
13!10         //ditto

10.do({ arg i; i.postln;}) //do a function 10 times (more on this later)

//convenient conversion methods
60.midicps
440.cpsmidi
4.octcps
72.midicps.cpsoct.round
0.dbamp
0.5.ampdb
0.75.ampdb
-60.dbamp

//quick random numbers
100.xrand  //return a random number between 0 and 99
100.xrand2 //return a random number between +/- 100

//a few methods for floats only
3.5.round  //rounds to next higher number
3.25.round //rounds to next lower number
3.25.roundUp //force SC to round up
pi.round
1.23456789.round(0.001)
45.1.ceil //next greater integer
45.1.floor //next smaller integer
0.5.coin  //returns true 50% of the time (Floats only)

// For many more, check out the manual for Integer, Float, and SimpleNumber

//Exponential notation is also supported
1.4e4 //moves the decimal point 4 places to the right
2e-2  //moves the decimal point 2 places to the left

//Radix (allows numbers to be specified in bases other than 10)
//Rarely used, and most methods available to simple numbers not supported
2r01011010 //binary notation
16r7F      //hexadecimal notation
8r7000     //octal notation
8r7654.postln //this throws an error
(8r7654).postln //this is OK, because it has been resolved to an integer

//Characters (single letters & numbers preceded by a $)
$A.class  //What are you?
$b
$1
//special characters preceded by a \
$\t //tab
$\n //newline
$\r //return
$\\ //the slash character

$\t.post;$A.post;$\t.post;$B.post;$\n.post;$\t.post;$C.postln;

//Strings (character(s) contained within double quotes)
"Hello!".class  //explain yourself
"2" //not at all the same thing as 2 (an integer)
"Most characters are OK, but a \\ signifies \n something \t special!\n".post
"This
 is
 a
 multiline
 string" //Be sure to select all the lines, then evaluate

//Symbols (character(s) contained within single quotes
'Hello!'.class  //explain yourself
\Hello.class    //symbols can also be indicated by a preceding backslash
                //but only if they do not contain spaces
\What about this? //throws an error
'What about this?' //OK
\My_Carrier_Frequency //OK
'2'             //not the same as "2" or 2, let alone 2.0
\2              //ditto

//Identifiers (methods and variables)
// ...must begin with a lower case alphabetic character (a-z),
// optionally followed by one or more alphanumric characters.
// The underscore character _ is OK, too.
var amp, mod_amp, sig200, theFundamental ; //all valid variable names

//Class Names (begin with a capital letter, optionally followed by
//one or more alphanumeric characters. Examples:

Synth //these just return themselves, if evaluated
Env
Array
Float
Pan2







