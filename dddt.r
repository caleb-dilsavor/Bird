library('warbleR')
for (i in 1:10){
checkwavbit<-3
tryCatch(checkwavs(),error=function(e){checkwavbit<-1})
print(checkwavbit)
}
