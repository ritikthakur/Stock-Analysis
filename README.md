# Stock-Analysis
Stock price Forecast on RStudio

This project is an attempt to forecast stock prices.
As stock values change with time and are affected by other indicators that may or may not substantiate its real value, we can use a time-series model that examines differences in the values in the series instead of actual values. This falls perfectly in line with the regression analysis, or more specifically, an ARIMA model.

The stock chosen for analysis in this project is RELIANCE.NS.
We perform multiple statistical checks on different forms of stock returns and program a flexible ARIMA model that can be used for any stock.

![RELIANCE](https://user-images.githubusercontent.com/51287188/112314715-578e6200-8ccf-11eb-9b78-4235b93d2ea6.png)

![Classical Decomposition](https://user-images.githubusercontent.com/51287188/112314891-8dcbe180-8ccf-11eb-847e-1ddd5143a939.png)

![logreturns   square root returns](https://user-images.githubusercontent.com/51287188/112314999-a89e5600-8ccf-11eb-80e7-7b309097b555.png)

![Diiferences Returns](https://user-images.githubusercontent.com/51287188/112315043-b6ec7200-8ccf-11eb-91e5-14af07708c69.png)

![Log_acf_pacf](https://user-images.githubusercontent.com/51287188/112315440-282c2500-8cd0-11eb-9a2d-b89c5ecd51ac.png)

![sqrt_acf_pacf](https://user-images.githubusercontent.com/51287188/112315077-bfdd4380-8ccf-11eb-8eca-681d4e9014a2.png)

![Actual_Forecasted](https://user-images.githubusercontent.com/51287188/112315084-c1a70700-8ccf-11eb-834f-5974adc245f6.png)
