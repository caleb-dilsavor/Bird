

# Birds in Random Forests
This is the winning project of [Erdös Institute](https://erdosinstitute.org)'s Data-science-boot-camp 2019. We classify croudsourced audio recordings of bird songs from [Xeno-Canto.org](https://www.xeno-canto.org).

## Introduction
Xeno-canto ([xeno-canto.org](https://www.xeno-canto.org)) is a bird sound crowdsourcing website that has hundreds of thousands (and counting) of recordings from around the world contributed by researchers, scientists, as well as general public. It contains bird sounds and detailed metadata including geotag, time, audio quality, and species name, etc.

In this project we are exploring a small subset of the database by filtering for only high quality birdsong recordings originated from United States. We extract nearly 23,000 feature vectors from about 8,000 recordings and test various classifiers using labels provided in metadata. Following is a bried summary of classifiers tested, along with their accuracy.

|Classifier|Accuracy (top 10 labels)|Accuracy (top 78 labels)
|----------|------------------------|------------------------|
|Logistic regression|17.7%|4.9%|
|SVC|18.4%|4.7%|
|LDA|49.4%|25.3%|
|K-neighbors|60.9%|42.1%|
|Decision Tree|65.8%|44.8%|
|Random Forest (RF)|79.4%|66.0%|
|RF + Adaboost|80.6%|65.2%|
|Extremely RF|83.5%|70.4%|

## Getting Started
### Installing Dependencies
You need the following dependencies installed to walk through this project:
1. R language (version 3.6.0+, 64-bit) ([r-project.org](https://cran.r-project.org))
2. R packages [warbleR](https://github.com/cran/warbleR) and [tuneR](https://github.com/cran/tuneR)

In R:
```R
install.packages("warbleR")
install.packages("tuneR")
```
3. Python language (version 3.7.3+) [python.org](https://www.python.org)
4. [Minoconda](https://conda.io/en/latest/miniconda.html)
Alternatively, you can install the following packages with pip3.

First run `pip3 install --upgrade pip`

|                               |Installation                 |
|-------------------------------|-----------------------------|
|jupyter                        |`pip3 install jupyter`        |
|numpy                          |`pip3 install numpy`          |
|pandas                         |`pip3 install pandas`         |
|sklearn                        |`pip3 install sklearn`        |
|matplotlib                     |`pip3 install matplotlib`     |
### Walkthrough
1. Start by downloading data using `download_data.r` (a dataset we downloaded for testing is provided in the repository).
```sh
$ Rscript download_data.r
```
This will create a `Data/` directory and start downloading data and extracting features. To change the scope of what you want to download, change the query in line 24:
```R
Q.results <- querxc('cnt:"United States" q: A', download = FALSE) 
```
For more information about Xeno-Canto queries, refer to [Xeno-Canto search tips](https://www.xeno-canto.org/help/search).

**Note:** Downloading and feature extraction can be a time consuming process. If you have to rerun `download_data.r` multiple times you can 1) change the range in the following loop accordingly (line 61):
```R
for(song in 1:nrow(Q.results.songs)){
	...
}
```
and 2)  rename the data directory after each run so that new data don't overwrite previous data, and then 3) open `concat_features.ipynb` in `jupyter notebook` and follow the instructions to concatenate all data.

3. Follow `Classification.ipynb` (some of the classifiers we tried out), `PlotsAndModels10.ipynb` (classification of top 10 most frequent labels), and `PlotsAndModels78.ipynb` (classification of top 78 most frequent labels) by running them in jupyter notebook:
```sh
$ jupyter notebook
```
