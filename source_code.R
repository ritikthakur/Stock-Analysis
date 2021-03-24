# packages used in this project
library(forecast)
library(quantmod)
library(tseries)
library(timeSeries)
library(xts)
library(urca)

# variable plug-ins
stockname = "RELIANCE.NS"
startdate = "2010-01-01"
enddate = "2020-07-17"

# Pull data from Yahoo finance
stockvar = getSymbols(c(stockname), src = "yahoo", from=startdate, to=enddate, 
                      verbose = TRUE, warnings = FALSE, auto.assign = FALSE)
stockvar = na.omit(stockvar)

# chart time series
chartSeries(stockvar, theme = "black", name=c(stockname)[1])

# Pull close prices, we use close prices as the benchmark for future predictions, as those values are assumed to
# best reflect the changes in real values of the stock during the time frame.
price = stockvar[,4]

# On briefly looking at the data, we can see that the stock value increased over time since 2017:Q3 and 
# is at its peak value at the time of this analysis, i.e. 2020-07-19. There is no apparent pattern that can be used 
# to scale the values of the stock prices because trends are not linear. 
# as the stock price spikes, first apparent in late 2018, it is followed by a downward trend and thus the variance 
# between the data pounts appers to increase, with stock prices being especially volatile at the most recent dates.

# To further analye trends in the data, we can decompose the data into seasonal and trend components. 
stockvar.ts = ts(price, start = 2010-01-04, frequency = 165)
stockvar.de = decompose(stockvar.ts, type = "additive") 
plot(stockvar.de)

# The trend is overall increasing. From the Seasonal component, the stock seems to have a trough in Q1 and its peak at the end of the Q4.
# One notable observation in the white noise is that from 2018 the plot shows more fluctuation, meaning there is 
# greater variance and greater statistical error, implying more recent and future points become more unpredictable.

# Extracting the logarithmic returns and the square root values from the prices.
# Fluctuations in prices transformed into returns can be bettet compared over time and used to describe trends.
par(mfrow = c(2,1))
# logarithmic returns 
logprice = log(price)
plot(logprice, type = "l", 
     xlab="Time", ylab="Log(Price)", main = "Logarithmic Price Returns")

# Square root values instead raw values are used to scale the volatility between the points to manage the time horizon of the stock.
sqrtprice = sqrt(price)
plot(sqrtprice, type="l", xlab="Time", ylab="Sqrt(Price)", main = "Square Root Price Returns")

# The range of values of the y-axis are much smaller than the values in the observed data, transformed data is more linear.
# To smooth the data even more, we want to remove the fluctuations in data altogether, as a requirement of the Integration part of the ARIMA model,
# we difference the logarithmic returns and the square root values to turn the data into its stationary form.

# Differenced logarithmic Price Returns
dlogprice = diff(log(price), lag=1)
dlogprice = dlogprice[!is.na(dlogprice)]
plot(dlogprice, type = "l", xlab="Time", ylab="Log(Price)", main="Differenced Logarithmic Price Returns")

# Differenced Square root price returns
dsqrtprice = diff(sqrt(price), lag=1)
dsqrtprice = dsqrtprice[!is.na(dsqrtprice)]
plot(dsqrtprice, type = "l", xlab="Time", ylab="Sqrt(Price)", main="Differenced Square Root Price Returns")

# Viewing the y-axis, transformed data is now osciallating around 0. The deviations from are much smaller, data has been smoothed more.

# Before fitting the ARIMA model, we have to confirm that the data is actually usable, by performing an ADF test.
# with ARIMA model, the hypothesis in this context are to confirm stationarity.

# test for unit root 
summary(ur.df(logprice, type = "trend", lags = 12, selectlags = "AIC"))
summary(ur.df(sqrtprice, type = "trend", lags = 12, selectlags = "AIC"))
summary(ur.df(dlogprice, type = "trend", lags = 12, selectlags = "AIC"))
summary(ur.df(dsqrtprice, type = "trend", lags = 12, selectlags = "AIC"))

# From the Dickey-Fuller Statistic it is evident to use the diffrenced loagarithmic returns and square root values 
# instead of the log and sqrt prices.

# Creating Correlograms to find the ARIMA(p,d,q) notation
par(mfrow = c(2,1))
# ACF & PACF for log data
acf(dlogprice, main = "ACF for Logarithmic Price Returns")
pacf(dlogprice, main = "PACF for Logarithmic Price Returns")

par(mfrow=c(2,1))
# ACF & PACF for log data
acf(dsqrtprice, main = "ACF for Square Root Price Returns")
pacf(dsqrtprice, main = "PACF for Square Root Price Returns")

# On viewing the ACF plot for the logarithmic returns, the cutoff for strong correlation is as lag 1, which means q-notation is 1.
# With the PACF pot, the cut-off seems to be quite high, 14, giving p-notation 14, so we get the model ARIMA(14,0,1)
# The d-notation for the ARIMA model is the number of non-seasonal differences needed for stationarity.
# Since logarithmic returns and square root values, though scaled, may still contain seasonal trends, we do not count the differences done here as part of the notation. Therefore, the d-notation is 0 for both datasets.
# Interestingly enough, the same p, d , q values for Square root returns, ARIMA(14,0,1)

# Initialize real log returns via xts
realreturn <- xts(0, as.Date("2016-12-09", "%Y-%m-%d"))
# Initialize forecasted returns via dataframe
forecastreturn = data.frame(Forecasted = numeric())

# for loop below is the working model that forecasts returns for each datapoint, and returns a time series for both real and forecast returns.

split <- floor(nrow(dlogprice)*(2.7/3)) # splits the dataset into training and testing set by introducing a breakpoint.
for( i in split:(nrow(dlogprice)-1)) {
  
  dlogprice_training <- dlogprice[1:i,]
  dlogprice_testing <- dlogprice[(i+1):nrow(dlogprice),]
  
  fit <- arima(dlogprice_training, order = c(14,0,1), include.mean=FALSE) # the AIC, which measures the relative amount of data lost is very negaive, a godd sign
  summary(fit)
  
  arima.forecast <- forecast(fit, h=1) # one-day ahead forecast of each data point of the fitted ARIMA Model
  summary(arima.forecast)
  
  Box.test(fit$residuals, lag=1, type="Ljung-Box")    # tests the overall randomness, or lack of fit of each residual on a group of lags in the data. 
  
  forecastreturn <- rbind(forecastreturn,arima.forecast$mean[1]) 
  colnames(forecastreturn) = c("Forecasted")
  returnseries <- dlogprice[(i+1),]
  realreturn <- c(realreturn, xts(returnseries))
  rm(returnseries)
}

realreturn <- realreturn[-1]
forecastreturn <- xts(forecastreturn, index(realreturn))
plot(realreturn, type = "l", main = "Actual Returns (Black) Vs Forecast Returns (Red)")
lines(forecastreturn, lwd=2, col="red")

# This graph is specific to the RELIANCE.NS stock returns over the testing period. The Black line for actual returns 
# serves as a benchmark for what happened in reality. The Red line for forecast returns serves as the prediction for the 
# increase or decrease in a return. 

# The following code merges the real and forecast return series from the testing sets, creates a binary comparison, and computes an accuracy percentage.
comparison <- merge(realreturn, forecastreturn)
comparison$Accuracy <- sign(comparison$realreturn) == sign(comparison$Forecasted)
print(comparison)

Accuracy_percentage <- sum(comparison$Accuracy == 1)*100/length(comparison$Accuracy)
print(Accuracy_percentage)

# The model is 73.08 % accurate when making a forecast of an increase or decrease in the logarithmic return of a stock.

# The RELIANCE.NS stock has grown over time, and if the trend continues, it should continue to grow. Based on the model, the values are likely to increase,
# as the forecast returns are more often above 0 than below.
