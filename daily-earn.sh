# for Training and Using

find _folder-path_ -type f -name ‘*.log’ -exec grep -l ERROR {} \;
#similar search 
grep -H "ERROR" _folder-path_*.log | cut -d: -f1

## 
