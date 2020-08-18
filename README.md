# Telecom Churn Analysis

Telecom customer churn analysis using Rstudio for the analysis.The dataset used is from IBM Sample Data Sets for customer retention programs. 

# About the data

> Customers who left  and moved on to another operator within the last month or within 2-3 months – the column is called Churn
> Services that each customer had been taking during the tenure – phone, multiple lines, internet, online security, online backup, device protection, tech support, and streaming TV and movies
> Customer account information – tenure of the customer, contract, payment method, paperless billing, monthly charges, and total charges
> Demographics info about customers – gender, age , and if they have partners and dependents

# More details about the data

> There are 7043 observations with 21 variables.
> 11 null values in the total charges column
> Tenure,monthly charges and total charges are in 'int' form so we convert it into categorical and perform Exploratory data analysis on hte dataset.
> From the EDA performed we found out that Around 26% of customers left the platform within the last month.
> Gender - The churn percent is almost equal in case of Male and Females
> The percent of churn is higher in case of senior citizens
> Customers with Partners and Dependents have lower churn rate as compared to those who don't have partners & Dependents.
> Churn rate is much higher in case of Fiber Optic InternetServices.
> Customers who do not have services like No OnlineSecurity , OnlineBackup and TechSupport have left the platform in the past month.
> A larger percent of Customers with monthly subscription have left when compared to Customers with one or two year contract.
> Churn percent is higher in case of cutsomers having paperless billing option.
> Customers who have ElectronicCheck PaymentMethod tend to leave the platform more when compared to other options.


# Data Preparation steps

> Cleaning the Categorical features
> Standardising the Continuous features
> Creating derived features
> Creating dummy variables for factor variables
> Creating the final dataset binding both the dataframes
> Splitting the data into train and validation set

# Machine Learning 

> We have performed three machine learning algorithms on out cleaned and training dataset like Logistic Regression,Decision Trees and Random forest
> We have evaluated the multicollinearity from the data to identify the variables/columns of multicollinearity we have used Variance Inflation factor(VIF) and removed the least   signifcant factors from the dataset and trained our data for logistic regression model.

# Logistic Regression:
Accuracy 75.59%,
Sensitivity 75.75%
Specificity 75.53%

# DecisionTrees:
Accuracy 78.1%,
Sensitivity 82.45%
Specificity 61.38%

# RandomForest:

Accuracy 78.26%,
Sensitivity 82.46%
Specificity 63.99%


# AUC curve of all the three models

Referred to http://rstudio-pubs-static.s3.amazonaws.com/277278_427ca6a7ce7c4eb688506efc7a6c2435.html when creating the AUC curves.

The ROC curve above shows that the Random Forest outperformed the Decision Tree model by a considerable amount.Only Random fores is a useful model for our inference,over the two other models which have performed similar which is useful enough for model interpretability but not so much for prediction performance. The Random Forest is the best tree based predictive model.








