@SDA @TradeFinance
Feature: Trade Finance use case for payment "At Maturity" and Maturity Date is NULL
    #To Simulate this test scenario under Create Annex, maturity date is set to current date and end date to 1 month before that.

  Background:
    * call read('classpath:features/common/Background.feature')


  Scenario Outline: Checker approves the request for <paymentFrequency> Payment schedule and currency <currency>

  #Create test data Jsons
  #start(effective) date is set to 30 months before the current date
    * def data = { "paymentFrequency": "<paymentFrequency>", "currency": "<currency>", "month": 30, "maturityDate": null }
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

  #Create UCP Agreement with Null maturity date
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


  #Calculate Remuneration fees - We get 400 error here since maturityDate was null
    Given  url baseUrl+'/calculate_fees?calculation_period_id='+calculationPeriodId
    When method GET
    Then status 400
    And match $.error_code == "invalid_maturity_date"
    And match $.detail == "Payment frequency AtMaturity requires a maturity_date"

  #Update UCP Agreement with Maturity Date
    * configure headers = { "X-API-Key": #(eventsKey) }
    * def effectiveDate = testUtil.getDateAfterSubtractingMonths((30))
    Given  url baseUrl+'/ucp_agreements/'+ucpId
    And request updateUcpAgreementPayload
    And header Authorization = 'checker_abhi@example.com'


    And set createUcpAgreementPayload.participation_reference_number = participationReferenceNumber

    And set updateUcpAgreementPayload.currency = '<currency>'
    # set maturity date to current date
    And set updateUcpAgreementPayload.maturity_date = currentDate
    And set updateUcpAgreementPayload.effective_date = effectiveDate
    And set updateUcpAgreementPayload.updated_at = '2024-05-13T00:00:00+00:00'
    When method PUT
    Then status 200
    And match $.obligor_number == obligorNum
    And match $.contract_code == contractCode
    And match $.ucp_id == ucpId

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
      | paymentFrequency | currency |
      | AtMaturity       | EUR      |
      | AtMaturity       | GBP      |
      | AtMaturity       | USD      |