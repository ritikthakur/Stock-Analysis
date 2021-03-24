# Stock-Analysis
Stock price Forecast on RStudio

This project is an attempt to forecast stock prices.
As stock values change with time and are affected by other indicators that may or may not substantiate its real value, we can use a time-series model that examines differences in the values in the series instead of actual values. This falls perfectly in line with the regression analysis, or more specifically, an ARIMA model.

The stock chosen for analysis in this project is RELIANCE.NS.
We perform multiple statistical checks on different forms of stock returns and program a flexible ARIMA model that can be used for any stock.

![RELIANCE](https://user-images.githubusercontent.com/51287188/112314715-578e6200-8ccf-11eb-9b78-4235b93d2ea6.png)

On briefly looking at the data, we can see that the stock value increased over time since 2017:Q3 and is at its peak value at the time of this analysis, i.e. 2020-07-19. There is no apparent pattern that can be used to scale the values of the stock prices because trends are not linear as the stock price spikes, first apparent in late 2018, it is followed by a downward trend and thus the variance  between the data pounts appers to increase, with stock prices being especially volatile at the most recent dates.

![Classical Decomposition](https://user-images.githubusercontent.com/51287188/112314891-8dcbe180-8ccf-11eb-847e-1ddd5143a939.png)

The trend is overall increasing. From the Seasonal component, the stock seems to have a trough in Q1 and its peak at the end of the Q4. One notable observation in the white noise is that from 2018 the plot shows more fluctuation, meaning there is greater variance and greater statistical error, implying more recent and future points become more unpredictable.

![logreturns   square root returns](https://user-images.githubusercontent.com/51287188/112314999-a89e5600-8ccf-11eb-80e7-7b309097b555.png)

Square root values instead raw values are used to scale the volatility between the points to manage the time horizon of the stock.
The range of values of the y-axis are much smaller than the values in the observed data, transformed data is more linear.
Fluctuations in prices transformed into returns can be bettet compared over time and used to describe trends.

![Diiferences Returns](https://user-images.githubusercontent.com/51287188/112315043-b6ec7200-8ccf-11eb-91e5-14af07708c69.png)

Viewing the y-axis, transformed data is now osciallating around 0. The deviations from are much smaller, data has been smoothed more.

![Log_acf_pacf](https://user-images.githubusercontent.com/51287188/112315440-282c2500-8cd0-11eb-9a2d-b89c5ecd51ac.png)

![sqrt_acf_pacf](https://user-images.githubusercontent.com/51287188/112315077-bfdd4380-8ccf-11eb-8eca-681d4e9014a2.png)

On viewing the ACF plot for the logarithmic returns, the cutoff for strong correlation is as lag 1, which means q-notation is 1.
With the PACF pot, the cut-off seems to be quite high, 14, giving p-notation 14, so we get the model ARIMA(14,0,1)
The d-notation for the ARIMA model is the number of non-seasonal differences needed for stationarity.
Since logarithmic returns and square root values, though scaled, may still contain seasonal trends, we do not count the differences done here as part of the notation. Therefore, the d-notation is 0 for both datasets.
Interestingly enough, the same p, d , q values for Square root returns, ARIMA(14,0,1)

![Actual_Forecasted](https://user-images.githubusercontent.com/51287188/112315084-c1a70700-8ccf-11eb-834f-5974adc245f6.png)

This graph is specific to the RELIANCE.NS stock returns over the testing period. The Black line for actual returns 
serves as a benchmark for what happened in reality. The Red line for forecast returns serves as the prediction for the 
increase or decrease in a return.

The model is 73.08 % accurate when making a forecast of an increase or decrease in the logarithmic return of a stock.

The RELIANCE.NS stock has grown over time, and if the trend continues, it should continue to grow. Based on the model, the values are likely to increase,
as the forecast returns are more often above 0 than below.
