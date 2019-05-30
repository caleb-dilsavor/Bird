library('warbleR')
for (i in 1:10){
checkwavbit<-3
tryCatch(checkwavs(),error=function(e){next})
print(checkwavbit)
}
