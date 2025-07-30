//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
    /* Icon   */    /* Command */                                                                                      /* Interval */    /* Signal */
    { "   ",      "top -bn1 | awk '/^%Cpu/ { printf \"%.1f%%\\n\", 100 - $8 }'",                                      1,              0 },
    { "   ",      "free -h | awk '/^Mem/ { print $3 }' | sed 's/i//g'",                                               1,              0 },
    { "   ",      "echo \"$(cat /sys/class/power_supply/BAT0/capacity)%\"",                                          15,             0 },
    { " 󰥔  ",      "date '+%H:%M:%S'",                                                                                1,              0 },
    { "   ",      "date '+%d:%m:%Y'",                                                                                1,              0 },
};

//sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char delim[] = " ";
static unsigned int delimLen = 5;
