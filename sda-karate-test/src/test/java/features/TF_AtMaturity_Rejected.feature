@SDA @TradeFinance
  Feature: Trade Finance use case for payment "At Maturity" when Checker rejects the request created by Maker
  #To Simulate this test scenario under Create Annex, maturity date is set to current date and end date to 1 month before that.

  Background:
    * call read('classpath:features/common/Background.feature')

  Scenario Outline: Checker rejects the request for <paymentFrequency> Payment schedule and currency <currency>

  #Create test data Jsons
  #start(effective) date is set to 30 months before the current date
    * def data = { "paymentFrequency": "<paymentFrequency>", "currency": "<currency>", "month": 30, "maturityDate": #(currentDate) }
    * def notification = { "expected_type": "to_be_replaced", "expected_calculation_period_id": null, "authorization_header": "to_be_replaced" }
    * def checkerReview = { "status": "to_be_replaced" }
    * def availmentData = { "payload": "to_be_replaced" }
    * def annexData = { "payload": "to_be_replaced" }


  # Create Obligor
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

  #Checker rejects the review
    * checkerReview.status = "rejected"
    * notification.authorization_header = 'checker_abhi@example.com'
    * call read('classpath:features/common/ReviewStatusUpdates.feature')

  #Verify Review is rejected
    * notification.authorization_header = 'maker_abhi@example.com'
    * notification.expected_type = 'review_rejected'
    * notification.expected_calculation_period_id = calculationPeriodId
    * call read('classpath:features/common/GetNotification.feature')

  #Maker resolves the comments
    * checkerReview.status = "resolved"
    * notification.authorization_header = 'maker_abhi@example.com'
    * call read('classpath:features/common/ReviewStatusUpdates.feature')

  #Verify review_again status
    * notification.authorization_header = 'checker_abhi@example.com'
    * notification.expected_type = 'review_again'
    * notification.expected_calculation_period_id = calculationPeriodId
    * call read('classpath:features/common/GetNotification.feature')

  #Checker approves the review
    * checkerReview.status = "approved"
    * notification.authorization_header = 'checker_abhi@example.com'
    * call read('classpath:features/common/ReviewStatusUpdates.feature')

  #Store the fee calculations
    * call read('classpath:features/common/StoreFeeCalculations.feature')

  #Create Payment Advice
    * call read('classpath:features/common/CreatePaymentAdvice.feature')

  #Download Payment Advice PDF
    * call read('classpath:features/common/GetPaymentAdvicePdf.feature')

    Examples:
      | paymentFrequency | currency |
      | AtMaturity       | EUR      |
      | AtMaturity       | GBP      |
      | AtMaturity       | USD      |