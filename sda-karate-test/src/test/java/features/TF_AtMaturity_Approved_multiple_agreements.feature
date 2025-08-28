@SDA @TradeFinance
  Feature: Trade Finance use case for payment "At Maturity" when Checker approves the request created by Maker for multiple agreements per contract
    #To Simulate this test scenario under Create Annex, maturity date is set to current date and end date to 1 month before that.

  Background:
    * call read('classpath:features/common/Background.feature')


  Scenario Outline: Checker approves the request for <paymentFrequency> Payment schedule and currency <currency>

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

  #Create UCP Agreement
      * notification.authorization_header = 'maker_abhi@example.com'
      * call read('classpath:features/common/CreateUcpAgreement.feature')
  #Create Another UCP Agreement
  #Here we are creating multiple agreements for same Contract and making sure the flow works fine
    * notification.authorization_header = 'maker_abhi@example.com'
    * call read('classpath:features/common/CreateUcpAgreement2.feature')

  #Create Annex
      * notification.authorization_header = 'maker_abhi@example.com'
      * annexData.payload = createAnnexByContractPayload
      * call read('classpath:features/common/CreateAnnex.feature')
  #Create Annex 2
    * notification.authorization_header = 'maker_abhi@example.com'
    * annexData.payload = createAnnex2ByContractPayload
    * configure headers = { "X-API-Key": #(eventsKey) }
    Given  url baseUrl+'/annexes'
    And request annexData.payload
    And header Authorization = notification.authorization_header
    And set annexData.payload.annex_id = annexId2
    And set annexData.payload.ucp_id = ucpId2
    When method POST
    Then status 201
    And match $.annex_id == annexId2
    And match $.ucp_id == ucpId2


  #Create BPS Remuneration fees
    * call read('classpath:features/common/CreateRenumerationFees.feature')


  #Create Notifications
    * call read('classpath:features/common/CreateNotifications.feature')

    * configure headers = { "X-API-Key": #(eventsKey) }
    #Maker(created_by) needs to be the same as the one in the latest annex
    * param created_by = 'maker_abhi@example.com'
    Given  url baseUrl+'/notifications'
    And request createNotificationsPayload
    And set createNotificationsPayload.ucp_id = ucpId2
    And set createNotificationsPayload.contract_code = contractCode
    And set createNotificationsPayload.atlas_facility_id = null
    When method POST
    Then status 201
    And match $.ucp_id == ucpId2


  #Get calculation period id
    * call read('classpath:features/common/GetCalculationPeriodId.feature')
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/calculation_periods?ucp_id='+ucpId2
    When method GET
    Then status 200
    And match $.items[0].ucp_id == ucpId2
    * def calculationPeriodId2 = $.items[0].id


  #Verify agreement is added
    * notification.authorization_header = 'checker_abhi@example.com'
    * notification.expected_type = 'agreement_added'
    * notification.expected_calculation_period_id = null
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/notifications/'
    And header Authorization = notification.authorization_header
    When method GET
    Then status 200
    And match $.items[0].ucp_id == ucpId2
    And match $.items[0].type == notification.expected_type
    And match $.items[0].calculation_period_id == notification.expected_calculation_period_id
    And match $.items[1].ucp_id == ucpId
    And match $.items[1].type == notification.expected_type
    And match $.items[1].calculation_period_id == notification.expected_calculation_period_id

  #Post check-calculation-period
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/notifications/check-calculation-period/'+contractCode
    When method POST
    Then status 201
    And match $[0].ucp_id == ucpId
    And match $[0].type == "needs_review"
    And match $[0].contract_code == contractCode
    And match $[1].ucp_id == ucpId2
    And match $[1].type == "needs_review"
    And match $[1].contract_code == contractCode


  #Check the latest Notification
    * notification.authorization_header = 'checker_abhi@example.com'
    * notification.expected_type = 'needs_review'
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/notifications/'
    And header Authorization = notification.authorization_header
    When method GET
    Then status 200
    And match $.items[0].ucp_id == ucpId2
    And match $.items[0].type == notification.expected_type
    And match $.items[0].calculation_period_id == calculationPeriodId2
    And match $.items[1].ucp_id == ucpId
    And match $.items[1].type == notification.expected_type
    And match $.items[1].calculation_period_id == calculationPeriodId

  #Calculate Remuneration fees
#    Make sure Correct fees is calculated for both the Calculation Period Ids

    * def feeCalculationAmount = createAnnexByContractPayload.guarantor_participation_percentage * 0.01 * createAvailmentPayload.outstanding_liability_amount
    * def daysInYear =
    """
      function() {
        if (createUcpAgreementPayload.currency == "GBP") {
            return 365;
        } else {
            return 360;
        }
      }
    """
    * def numberOfDays = testUtil.calculateDateDifference(effectiveDate,currentDate)
    * def expectedFees = Number((numberOfDays * feeCalculationAmount * calculatedBpsValue / 10000 / daysInYear()).toFixed(2))
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/calculate_fees?calculation_period_id='+calculationPeriodId
    When method GET
    Then status 200
    And match $[0].day_count == numberOfDays
    * def formatNumber = function(num) { return Number(num.toFixed(2)); }
    * def actualFees = formatNumber(response[0].amount)
    And match actualFees == expectedFees


    * def feeCalculationAmount = createAnnex2ByContractPayload.guarantor_participation_percentage * 0.01 * createAvailmentPayload.outstanding_liability_amount
    * def daysInYear =
    """
      function() {
        if (createUcpAgreementPayload.currency == "GBP") {
            return 365;
        } else {
            return 360;
        }
      }
    """
    * def numberOfDays = testUtil.calculateDateDifference(effectiveDate,currentDate)
    * def expectedFees = Number((numberOfDays * feeCalculationAmount * calculatedBpsValue / 10000 / daysInYear()).toFixed(2))
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/calculate_fees?calculation_period_id='+calculationPeriodId2
    When method GET
    Then status 200
    And match $[0].day_count == numberOfDays
    * def formatNumber = function(num) { return Number(num.toFixed(2)); }
    * def actualFees = formatNumber(response[0].amount)
    And match actualFees == expectedFees


  #Checker approves the review
    * notification.authorization_header = 'checker_abhi@example.com'
    * checkerReview.status = "approved"
    * call read('classpath:features/common/ReviewStatusUpdates.feature')

    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/review_status_updates'
    And header Authorization = notification.authorization_header
    And request CreateReviewStatusUpdatePayload
    And set CreateReviewStatusUpdatePayload.calculation_period_id = calculationPeriodId2
    And set CreateReviewStatusUpdatePayload.status = checkerReview.status
    When method POST
    Then status 201
    And match $.calculation_period_id == calculationPeriodId2
    And match $.status == checkerReview.status

  #Verify Review is approved
    * notification.authorization_header = 'maker_abhi@example.com'
    * notification.expected_type = 'review_approved'
    * configure headers = { "X-API-Key": #(importKey) }
    Given  url baseUrl+'/notifications/'
    And header Authorization = notification.authorization_header
    When method GET
    Then status 200
    And match $.items[0].ucp_id == ucpId2
    And match $.items[0].type == notification.expected_type
    And match $.items[0].calculation_period_id == calculationPeriodId2
    And match $.items[1].ucp_id == ucpId
    And match $.items[1].type == notification.expected_type
    And match $.items[1].calculation_period_id == calculationPeriodId

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