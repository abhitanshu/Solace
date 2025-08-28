@SDA @TradeFinance
 #To Simulate this test scenario under Create Annex, end date is set to current date and start(effective) date to 1 or 3 or 12 month before that based on frequency

Feature: Trade Finance use case for payment frequencies Monthly/Quarterly/Yearly when Checker approves the request created by Maker

  Background:

    * call read('classpath:features/common/Background.feature')

  Scenario Outline: Checker approves the request for <paymentFrequency> Payment schedule and currency <currency>

#Create test data Jsons
    * def data = { "paymentFrequency": "<paymentFrequency>", "currency": "<currency>", "month": <month>, "maturityDate": #(currentDate)}
    * def notification = { "expected_type": "to_be_replaced", "expected_calculation_period_id": null, "authorization_header": "to_be_replaced" }
    * def checkerReview = { "status": "to_be_replaced" }
    * def availmentData = { "payload": "to_be_replaced" }
    * def annexData = { "payload": "to_be_replaced" }


  #Create Obligor
    * call read('classpath:features/common/CreateObligor.feature')


  #Create a Contract.
    * call read('classpath:features/common/CreateContract.feature')

  #Create an availment
    * availmentData.payload = createAvailmentPayload
    * call read('classpath:features/common/CreateAvailment.feature')

  #Create UCP Agreement
    * notification.authorization_header = 'maker_abhi@example.com'
    * call read('classpath:features/common/CreateUcpAgreement.feature')

  #Create Annex
    * notification.authorization_header = 'maker_abhi@example.com'
    * annexData.payload = createAnnexByContractPayload
    * call read('classpath:features/common/CreateAnnex.feature')
  #Create Annex 2
    * notification.authorization_header = 'maker_abhi@example.com'
    * annexData.payload = createAnnex2ByContractPayload
    * call read('classpath:features/common/CreateAnnex2.feature')


  #Create BPS Remuneration fees
    * call read('classpath:features/common/CreateRenumerationFees.feature')


  #Create Notifications
    * call read('classpath:features/common/CreateNotifications.feature')


  #Get calculation period id
    * call read('classpath:features/common/GetCalculationPeriodId.feature')

#Verify agreement is added
    * notification.authorization_header = 'checker_abhi@example.com'
    * notification.expected_type = 'agreement_added'
    * notification.expected_calculation_period_id = null
    * call read('classpath:features/common/GetNotification.feature')

  #Post check-calculation-period
    * call read('classpath:features/common/CheckCalculationPeriodWithContractCode.feature')

#Check the latest Notification
    * notification.authorization_header = 'checker_abhi@example.com'
    * notification.expected_type = 'needs_review'
    * notification.expected_calculation_period_id = calculationPeriodId
    * call read('classpath:features/common/GetNotification.feature')


  #Calculate Remuneration fees
    * call read('classpath:features/common/CalculateFees.feature')

#Checker approves the review
    * notification.authorization_header = 'checker_abhi@example.com'
    * checkerReview.status = "approved"
    * call read('classpath:features/common/ReviewStatusUpdates.feature')

  #Verify Review is approved
    * notification.authorization_header = 'maker_abhi@example.com'
    * notification.expected_type = 'review_approved'
    * notification.expected_calculation_period_id = calculationPeriodId
    * call read('classpath:features/common/GetNotification.feature')


  #Store the fee calculations
    * call read('classpath:features/common/StoreFeeCalculations.feature')


  #Create Payment Advice
    * call read('classpath:features/common/CreatePaymentAdvice.feature')


  #Download Payment Advice PDF
    * call read('classpath:features/common/GetPaymentAdvicePdf.feature')

    Examples:
      | paymentFrequency | currency | month |
      | Quarterly        | EUR      | 3     |
      | Monthly          | GBP      | 1     |
      | Yearly           | USD      | 12    |