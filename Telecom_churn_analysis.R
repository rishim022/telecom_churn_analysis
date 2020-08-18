library(tidyverse) 
library(MASS)
library(car)
library(e1071)
library(caret)
library(cowplot)
library(caTools)
library(pROC)
library(ggcorrplot)
telecom_churn <- read.csv("D://Telecom_churn//WA_Fn-UseC_-Telco-Customer-Churn.csv")
telecom_churn
glimpse(telecom_churn)
options(repr.plot.width = 6, repr.plot.height = 4)
missing_data <- telecom_churn %>% summarise_all(funs(sum(is.na(.))/n()))
missing_data <- gather(missing_data, key = "variables", value = "percent_missing")
ggplot(missing_data, aes(x = reorder(variables, percent_missing), y = percent_missing)) +
  geom_bar(stat = "identity", fill = "red", aes(color = I('white')), size = 0.3)+
  xlab('variables')+
  coord_flip()+ 
  theme_bw()

na_count <-sapply(telecom_churn, function(y) sum(length(which(is.na(y)))))
na_count <- data.frame(na_count)
na_count


telecom<-telecom_churn[complete.cases(telecom_churn),]
telecom$SeniorCitizen<-as.factor(ifelse(telecom$SeniorCitizen==1,'YES','NO'))
telecom



telecom %>% 
  group_by(Churn) %>% 
  summarise(Count = n())%>% 
  mutate(percent = prop.table(Count)*100)%>%
  ggplot(aes(reorder(Churn, -percent), percent), fill = Churn)+
  geom_col(fill = c("#FC4E07", "#E7B800"))+
  geom_text(aes(label = sprintf("%.2f%%", percent)), hjust = 0.01,vjust = -0.5, size =3)+ 
  theme_bw()+  
  xlab("Churn") + 
  ylab("Percent")+
  ggtitle("Churn Percent")




library(cowplot)

plot_grid(ggplot(telecom, aes(x=gender,fill=Churn))+ geom_bar()+ theme_bw(), 
          ggplot(telecom, aes(x=SeniorCitizen,fill=Churn))+ geom_bar(position = 'fill')+theme_bw(),
          ggplot(telecom, aes(x=Partner,fill=Churn))+ geom_bar(position = 'fill')+theme_bw(),
          ggplot(telecom, aes(x=Dependents,fill=Churn))+ geom_bar(position = 'fill')+theme_bw(),
          ggplot(telecom, aes(x=PhoneService,fill=Churn))+ geom_bar(position = 'fill')+theme_bw(),
          ggplot(telecom, aes(x=MultipleLines,fill=Churn))+ geom_bar(position = 'fill')+theme_bw()+
            scale_x_discrete(labels = function(x) str_wrap(x, width = 10)),
          align = "h")



plot_grid(ggplot(telecom, aes(x=InternetService,fill=Churn))+ geom_bar(position = 'fill')+ theme_bw()+
            scale_x_discrete(labels = function(x) str_wrap(x, width = 10)), 
          ggplot(telecom, aes(x=OnlineSecurity,fill=Churn))+ geom_bar(position = 'fill')+theme_bw()+
            scale_x_discrete(labels = function(x) str_wrap(x, width = 10)),
          ggplot(telecom, aes(x=OnlineBackup,fill=Churn))+ geom_bar(position = 'fill')+theme_bw()+
            scale_x_discrete(labels = function(x) str_wrap(x, width = 10)),
          ggplot(telecom, aes(x=DeviceProtection,fill=Churn))+ geom_bar(position = 'fill')+theme_bw()+
            scale_x_discrete(labels = function(x) str_wrap(x, width = 10)),
          ggplot(telecom, aes(x=TechSupport,fill=Churn))+ geom_bar(position = 'fill')+theme_bw()+
            scale_x_discrete(labels = function(x) str_wrap(x, width = 10)),
          ggplot(telecom, aes(x=StreamingTV,fill=Churn))+ geom_bar(position = 'fill')+theme_bw()+
            scale_x_discrete(labels = function(x) str_wrap(x, width = 10)),
          align = "h")



ggplot(telecom, aes(y= tenure, x = "", fill = Churn)) + 
  geom_boxplot()+ 
  theme_bw()+
  xlab(" ")


ggplot(telecom, aes(y= MonthlyCharges, x = "", fill = Churn)) + 
  geom_boxplot()+ 
  theme_bw()+
  xlab(" ")


ggplot(telecom, aes(y= TotalCharges, x = "", fill = Churn)) + 
  geom_boxplot()+ 
  theme_bw()+
  xlab(" ")


telecom<-data.frame(lapply(telecom,function(x){gsub("No internet service","No",x)}))
telecom<-data.frame(lapply(telecom,function(x){gsub("No phone service","No",x)}))


num_columns <- c("tenure", "MonthlyCharges", "TotalCharges")
telecom[num_columns] <- sapply(telecom[num_columns], as.numeric)
telecom_int <- telecom[,c("tenure", "MonthlyCharges", "TotalCharges")]
telecom_int <- data.frame(scale(telecom_int))
telecom_int



max(telecom$tenure)
min(telecom$tenure)

telecom<-mutate(telecom,tenure_bin=tenure)
telecom
telecom$tenure_bin[telecom$tenure_bin >=0 & telecom$tenure_bin <= 12] <- '0-1 year'
telecom$tenure_bin[telecom$tenure_bin > 12 & telecom$tenure_bin <= 24] <- '1-2 years'
telecom$tenure_bin[telecom$tenure_bin > 24 & telecom$tenure_bin <= 36] <- '2-3 years'
telecom$tenure_bin[telecom$tenure_bin > 36 & telecom$tenure_bin <= 48] <- '3-4 years'
telecom$tenure_bin[telecom$tenure_bin > 48 & telecom$tenure_bin <= 60] <- '4-5 years'
telecom$tenure_bin[telecom$tenure_bin > 60 & telecom$tenure_bin <= 72] <- '5-6 years'

telecom$tenure_bin <- as.factor(telecom$tenure_bin)

View(telecom)
ggplot(telecom, aes(tenure_bin, fill = tenure_bin)) + geom_bar()+ theme_bw()


telecom_categorical<- telecom[,-c(1,6,19,20)]
dummy<- data.frame(sapply(telecom_categorical,function(x) data.frame(model.matrix(~x-1,data =telecom_categorical))[,-1]))

head(dummy)

telecom_final<-cbind(telecom_int,dummy)
View(telecom_final)




set.seed(123)
indices <-sample.split(telecom_final$Churn, SplitRatio = 0.7)
train <-telecom_final[indices,]
validation <-telecom_final[!(indices),]

dim(train)
dim(validation)


model_1<-glm(Churn ~ ., data = train, family = "binomial")
summary(model_1)

model_2<- stepAIC(model_1, direction="both")


vif(model_2)



#Removing DeviceProtection due to high p-value 
model_3 <-glm(formula = Churn ~ tenure + MonthlyCharges + SeniorCitizen + 
                Partner + InternetService.xFiber.optic + InternetService.xNo + 
                OnlineSecurity + OnlineBackup + TechSupport + 
                StreamingTV + Contract.xOne.year + Contract.xTwo.year + PaperlessBilling + 
                PaymentMethod.xElectronic.check + tenure_bin.x1.2.years + 
                tenure_bin.x5.6.years, family = "binomial", data = train)
summary(model_3)

vif(model_3)


model_4 <- glm(formula = Churn ~ tenure + MonthlyCharges + SeniorCitizen + 
                 Partner + InternetService.xFiber.optic + InternetService.xNo + 
                 OnlineSecurity + OnlineBackup + TechSupport +  
                 Contract.xOne.year + Contract.xTwo.year + PaperlessBilling + 
                 PaymentMethod.xElectronic.check + tenure_bin.x1.2.years + 
                 tenure_bin.x5.6.years, family = "binomial", data = train)

summary(model_4)

vif(model_4)


final_model<-model_3

pred <- predict(final_model, type = "response", newdata = validation[,-24])
summary(pred)
validation$prob <- pred


# Using probability cutoff of 50%.

predicted_churn <- factor(ifelse(pred >= 0.50, "Yes", "No"))
actual_churn <- factor(ifelse(validation$Churn==1,"Yes","No"))
table(actual_churn,predicted_churn)

confusionMatrix((table(actual_churn,predicted_churn)))



set.seed(123)
telecom_final$Churn <- as.factor(telecom_final$Churn)

indices <-sample.split(telecom_final$Churn, SplitRatio = 0.7)
train <-telecom_final[indices,]
validation <-telecom_final[!(indices),]

library(rpart)
library(rpart.plot)

dtree_churn<-rpart(Churn~.,data=train,method="class")
summary(dtree_churn)


dtPred <- predict(dtree_churn,type = "class", newdata = validation[,-24])
confusionMatrix(validation$Churn,dtPred)



library(randomForest)

set.seed(123)
telecom_final$Churn <- as.factor(telecom_final$Churn)

indices <- sample.split(telecom_final$Churn, SplitRatio = 0.7)
train <-telecom_final[indices,]
validation <- telecom_final[!(indices),]


model_rf <- randomForest(Churn ~ ., data=train, proximity=FALSE,importance = FALSE,
                         ntree=500,mtry=4, do.trace=FALSE)
model_rf
testPrediction <- predict(model_rf, newdata=validation[,-24])
table(testPrediction, validation$Churn)

confusionMatrix(validation$Churn, testPrediction)


varImpPlot(model_rf)


glm.roc <- roc(response = validation$Churn, predictor = as.numeric(pred))
DT.roc <- roc(response = validation$Churn, predictor = as.numeric(dtPred))
rf.roc <- roc(response = validation$Churn, predictor = as.numeric(testPrediction))


plot(glm.roc,      legacy.axes = TRUE, print.auc.y = 1.0, print.auc = TRUE)
plot(DT.roc, col = "blue", add = TRUE, print.auc.y = 0.65, print.auc = TRUE)
plot(rf.roc, col = "red" , add = TRUE, print.auc.y = 0.85, print.auc = TRUE)
legend("bottom", c("Random Forest", "Decision Tree", "Logistic"),
       lty = c(1,1), lwd = c(2, 2), col = c("red", "blue", "black"), cex = 0.75)
