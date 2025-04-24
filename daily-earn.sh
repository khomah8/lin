# for Training and Using

find _folder-path_ -type f -name ‘*.log’ -exec grep -l ERROR {} \;
#similar search 
grep -H "ERROR" _folder-path_*.log | cut -d: -f1


## free
#[MB GB PB] size unites  


## tar 
$ tar -tvf tar55.tar
-rw-r--r-- root/root       208 2023-12-28 14:59 tar--t
-rw-r--r-- root/root        37 2023-12-28 14:57 tarr--t
/home/hpstandard 15:13 tar --delete -f tar55.tar tar--t
/home/hpstandard 15:23 tar --append -f tar55.tar tar--t 


## `intel_backlight` 
$ sudo brightnessctl  s  33  
Updated device 'intel_backlight':
Device 'intel_backlight' of class 'backlight':
	Current brightness: 33 (1%)
	Max brightness: 6009
$ sudo brightnessctl  s  3
Updated device 'intel_backlight':
Device 'intel_backlight' of class 'backlight':
	Current brightness: 3 (0%)
	Max brightness: 6009
$ sudo brightnessctl  g
298 

## less --forced_opening_binzry_file , --Numbering_lines;  
$ less  -f <not_so_text_file>  
$ less  -N <long_file_right_side_lines_numbered>  

