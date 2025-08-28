@SDA @TradeFinance
Feature: Trade Finance Annex Amendment done on the same date as  Amendment for payment "At Maturity" when Checker approves the request created by Maker
  #To Simulate this test scenario under Create Annex, maturity date is set to current date and end date to 1 month before that.
  # Amendment date is set in CreateAvailment_Amnd.json (day field) which is after the effective date and before the maturity date
  # A new version of annex is created between the contract start date and Amendment day.

  Background:
    * call read('classpath:features/common/Background.feature')

  Scenario Outline: For Annex Amendment done on the same date as Amendment use case Checker approves the request for <paymentFrequency> Payment schedule and currency <currency>

    #Create test data Jsons
    #start(effective) date is set to 30 months before the current date
    * def data = { "paymentFrequency": "<paymentFrequency>", "currency": "<currency>", "month": 30, "maturityDate": #(currentDate) }
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


#Create an availment2
    * availmentData.payload = createAvailmentPayloadAmnd
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

 #Create Annex amendment
    * notification.authorization_header = 'maker_abhi@example.com'
    * annexData.payload = createAnnexAmendmentSameDayPayload
    * call read('classpath:features/common/CreateAnnexAmendment.feature')

#Create BPS Remuneration fees
    * call read('classpath:features/common/CreateRenumerationFeesAnnexAmendment.feature')


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
    * call read('classpath:features/common/CalculateFeesAnnexAmndSameDay.feature')


# Checker approves the review
    Given  url baseUrl+'/review_status_updates'
    And header Authorization = 'checker_abhi@example.com'
    And request CreateReviewStatusUpdatePayload
    And set CreateReviewStatusUpdatePayload.calculation_period_id = calculationPeriodId
    And set CreateReviewStatusUpdatePayload.status = "approved"
    When method POST
    Then status 201
    And match $.calculation_period_id == calculationPeriodId
    And match $.status == "approved"


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
      | paymentFrequency | currency |
      | AtMaturity       | EUR      |
      | AtMaturity       | GBP      |
      | AtMaturity       | USD      |