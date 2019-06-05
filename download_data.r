sink("logfile", append=FALSE, split=TRUE)
library('warbleR')
library('tuneR')

# Create a new directory
dir.create(file.path(getwd(),"Data"))
setwd(file.path(getwd(),"Data"))

# Pauses code. Helpful for testing data files, etc
pause = function()
{
    if (interactive())
    {
        invisible(readline(prompt = "Press <Enter> to continue..."))
    }
    else
    {
        cat("Press <Enter> to continue...")
        invisible(readLines(file("stdin"), 1))
    }
}

# Query Xeno-Canto for all high-quality recordings of birds in USA
Q.results <- querxc('cnt:"United States" q: A', download = FALSE) 

#print("#view command output")
#View(Q.results)

print("# Find out number of available recordings")
nrow(Q.results) 

#print("# Find out how many types of signal descriptions exist in the Xeno-Canto metadata")
#levels(Q.results$Vocalization_type)

#print("How many recordings per signal type?")
#table(Q.results$Vocalization_type)

# There are many levels to the Vocalization_type variable. 
# Some are biologically relevant signals, but most just 
# reflect variation in data entry.
Q.results.songs <- droplevels(Q.results[grep("song", Q.results$Vocalization_type, ignore.case = TRUE), ])

print("# Check resulting data frame")
str(Q.results.songs) 

#print("# Now, how many recordings per locality")
#table(Q.results.songs$Locality)

#first filter by location
#Phae.lon.LS <- Phae.lon.song[grep("La Selva Biological Station, Sarapiqui, Heredia", Phae.lon.song$Locality,ignore.case = FALSE),]

# write metadata file
write.csv(Q.results.songs, "metadata.csv", row.names = FALSE)
#print("generating map # map in the graphic device (img = FALSE)")
#xcmaps(Q.results.songs, img = TRUE)

print("number of files after filtering USA,quality A,Only songs")
print(nrow(Q.results.songs))

print("# Loop starts and downnload file by file")
for(song in 1:nrow(Q.results.songs)){

# delete audio files from last iteration
unlink("*.mp3")
unlink("*.wav")

querxc(X=Q.results.songs[song,]) 

print(paste("Iteration =", song))

print(paste("file name is",Q.results.songs[song,12]))

# Ignore audio files bigger than 5 mb (we had a deadline to meet!)
sizet<-file.size(list.files(pattern=".mp3"))
size<-(sizet/10e5)
print(paste("file size in Bytes :",sizet,"in Mb :",size))
if (size>5){
	print(paste("the file ",Q.results.songs[song,12]," is too big it's size is",size))
	write.table(song,"files_skipped.csv",sep='/n',row.names = FALSE,col.names=FALSE,append= TRUE)
	next
}


possibleError <- tryCatch(
{
    mp3files <- list.files(pattern=".mp3")
    for(mp3file in mp3files){
        filename_without_ext <- tools::file_path_sans_ext(mp3file)
        wavfilename <- paste(filename_without_ext,".wav",sep="")
        mp3data <- readMP3(mp3file)
        writeWave(mp3data,wavfilename)
    }
},error = function(e){print(e)})


# Use checkwavs to see if wav files can be read
possibleError <- tryCatch(checkwavs(),error = function(e){print(e)})
if(inherits(possibleError,"error")) {
     
     unlink("*.mp3")
     unlink("*.wav")
	next
}


# Let's create a list of all the recordings in the directory"
wavs <- list.files(pattern="wav$")

# We will use this list to downsample the wav files so the following analyses go a bit faster
lapply(wavs, function(x) writeWave(downsample(readWave(x), samp.rate = 22050),filename = x))

# Let's first create a subset for playing with arguments 
sub <- wavs

# ovlp = 10 speeds up process a bit 
# tiff image files are better quality and are faster to produce
# but jpeg are much smaller
# Run autodetec to detect signal segments in the audio file
songs.ad <- autodetec(bp = c(2, 9), threshold = 20, mindur = 0.09, maxdur = 0.22, 
                     envt = "abs", ssmooth = 900, ls = TRUE, res = 100, 
                     flim= c(1, 12), wl = 300, set =TRUE, sxrow = 6, rows = 15, 
                     redo = TRUE, it = "jpeg", img = TRUE)
                     
print("show output of autodetec")
str(songs.ad)


# Only keep files with at least 3 signal segments
if(nrow(songs.ad)<3){
	
	unlink("*.mp3")
	unlink("*.wav")
	next

}
print("number of files from autodetect")
print(nrow(songs.ad))

# Calculate signal to noice ratio
songs.snr <- sig2noise(X = songs.ad[seq(1, nrow(songs.ad)), ], mar = 0.04)
#table(songs.snr)
#pause()

songs.hisnr <- songs.snr[ave(-songs.snr$SNR, songs.snr$sound.files, FUN = rank) <= 5, ]

#print("# Double check the number of selection per sound files") 
#table(songs.hisnr$sound.files)

write.csv(songs.hisnr, "selected_metadata.csv", row.names = FALSE)

# Note that the dominant frequency measurements are almost always more accurate
#trackfreqs(songs.hisnr, flim = c(1, 11), bp = c(1, 12), it = "tiff")

# We can change the lower end of bandpass to make the frequency measurements more precise
#trackfreqs(songs.hisnr, flim = c(1, 11), bp = c(2, 12), col = c("purple", "orange"),
#           pch = c(17, 3), res = 300, it = "tiff")

# If the frequency measurements look acceptable with this bandpass setting,
# that's the setting we should use when running specan() 

# Use the bandpass filter to your advantage, to filter out low or high background
# noise before performing measurements
# The amplitude threshold will change the amplitude at which noises are
# detected for measurements 
params <- specan(songs.hisnr, bp = c(1, 11), threshold = 15)

#View(params)

str(params)

write.table(params, "feature_vectors.csv", sep=',',row.names = FALSE,col.names=FALSE,append= TRUE)
#pause()
unlink("*.mp3")
unlink("*.wav")
}

split()


