@TCF_Commodities @Ignore
Feature: To Verify TCF Commodity Positive Use case

  Background:
    * def testUtil = Java.type('util.KarateTestUtil')
    * def obligorNum = testUtil.getRandomObligerNumber()
    * def facilityId = testUtil.getRandomString(8)
    * def contractCode1 = testUtil.getRandomContractCode(16)
    * def contractCode2 = testUtil.getRandomContractCode(16)
    #participationReferenceNumber is not unique but using a different reference number for each request for convenience in debugging
    * def participationReferenceNumber = testUtil.getRandomString(10)

    * def createObligorPayload = read('classpath:resources/TestData/CreateObligor.json')
    * def createFacilityPayload = read('classpath:resources/TestData/CreateFacility.json')
    * def createContractPayload = read('classpath:resources/TestData/CreateContract.json')
    * def createAvailmentPayload = read('classpath:resources/TestData/CreateAvailment.json')
    * def createAnnexByFacilityPayload = read('classpath:resources/TestData/CreateAnnexByFacility.json')
    * def createPaymentSchedulePayload = read('classpath:resources/TestData/CreatePaymentSchedule.json')
    * def createRenumerationFeesFixedPayload = read('classpath:resources/TestData/CreateRenumerationFeesFixed.json')
    * def createRenumerationFeesBpsPayload = read('classpath:resources/TestData/CreateRenumerationFeesBps.json')
    * def createNotificationsPayload = read('classpath:resources/TestData/CreateNotifications.json')
    * def CreateReviewStatusUpdatePayload = read('classpath:resources/TestData/CreateReviewStatusUpdate.json')
    * def calculateFeesPayload = read('classpath:resources/TestData/CalculateFees.json')
    * def createPaymentAdvicePayload = read('classpath:resources/TestData/CreatePaymentAdvice.json')

  Scenario Outline: Trade Commodity use case for <paymentFrequency> Payment schedule

  # Create Obligor
    Given  url baseUrl+'/obligors'
    And request createObligorPayload
    And set createObligorPayload.number = obligorNum
    When method POST
    Then status 201
    And match $.name == createObligorPayload.name
    And match $.number == obligorNum

# Create Facility
    Given  url baseUrl+'/facilities'
    And request createFacilityPayload
    And set createFacilityPayload.atlas_facility_id = facilityId
    And set createFacilityPayload.obligor_number = obligorNum
    When method POST
    Then status 201

  #Create a Contract 1.
    Given  url baseUrl+'/contracts'
    And request createContractPayload
    And set createContractPayload.code = contractCode1
    And set createContractPayload.obligor_number = obligorNum
    And set createContractPayload.atlas_facility_id = facilityId
    When method POST
    Then status 201
    And match $.code == contractCode1
    And match $.obligor_number == obligorNum

    #Create a Contract 2.
    Given  url baseUrl+'/contracts'
    And request createContractPayload
    And set createContractPayload.code = contractCode2
    And set createContractPayload.obligor_number = obligorNum
    And set createContractPayload.atlas_facility_id = facilityId
    When method POST
    Then status 201
    And match $.code == contractCode2
    And match $.obligor_number == obligorNum

   #Create an availment for Contract1
    Given  url baseUrl+'/latest_availments'
    And request createAvailmentPayload
    And set createAvailmentPayload.contract_code = contractCode1
    When method POST
    Then status 201
    And match $.contract.code == contractCode1
    And match $.contract.obligor_number == obligorNum

    #Create an availment for Contract2
    Given  url baseUrl+'/latest_availments'
    And request createAvailmentPayload
    And set createAvailmentPayload.contract_code = contractCode2
    When method POST
    Then status 201
    And match $.contract.code == contractCode2
    And match $.contract.obligor_number == obligorNum


#Create Annex by Facility
    Given  url baseUrl+'/annexes'
    And request createAnnexByFacilityPayload
    And set createAnnexByFacilityPayload.atlas_facility_id = facilityId
    And set createAnnexByFacilityPayload.obligor_number = obligorNum
    And set createAnnexByFacilityPayload.participation_reference_number = participationReferenceNumber
    When method POST
    Then status 201
    And match $.obligor_number == obligorNum
    And match $.atlas_facility_id == facilityId
    And match $.participation_reference_number == participationReferenceNumber
    * def annexId = $.annex_id

#Create Payment Schedule
    Given  url baseUrl+'/payment_schedules'
    And request createPaymentSchedulePayload
    And set createPaymentSchedulePayload.annex_id = annexId
    And set createPaymentSchedulePayload.frequency = "<paymentFrequency>"
    When method POST
    Then status 201
    And match $.annex_id == annexId


#Create fixed Remuneration fees
    Given  url baseUrl+'/remuneration_fees'
    And request createRenumerationFeesFixedPayload
    And set createRenumerationFeesFixedPayload.annex_id = annexId
    When method POST
    Then status 201
    And match $.annex_id == annexId

#Create BPS Remuneration fees
    Given  url baseUrl+'/remuneration_fees'
    And request createRenumerationFeesBpsPayload
    And set createRenumerationFeesBpsPayload.annex_id = annexId
    When method POST
    Then status 201
    And match $.annex_id == annexId
    * def calculatedBpsValue = $.calculated_value

#Create Notifications
    Given  url baseUrl+'/notifications'
    And request createNotificationsPayload
    And set createNotificationsPayload.annex_id = annexId
    And set createNotificationsPayload.contract_code = null
    And set createNotificationsPayload.atlas_facility_id = facilityId
    When method POST
    Then status 201
    And match $.annex_id == annexId

# Verify agreement is added
    Given  url baseUrl+'/notifications/'
    When method GET
    Then status 200
    And match $.items[0].annex_id == annexId
    And match $.items[0].type == "agreement_added"

#Calculate Remuneration fees for contract 1
    * def feeCalculationAmount = createAvailmentPayload.maximum_contract_amount
    * def expectedFees = feeCalculationAmount * calculatedBpsValue / 10000 / <days>
    Given  url baseUrl+'/remuneration_fee_amounts'
    And request calculateFeesPayload
    And set calculateFeesPayload.contract_code = contractCode1
    When method POST
    Then status 201
    And match $[0].amount == 5
    And match $[1].amount == expectedFees

#Calculate Remuneration fees for contract 2
    Given  url baseUrl+'/remuneration_fee_amounts'
    And request calculateFeesPayload
    And set calculateFeesPayload.contract_code = contractCode2
    When method POST
    Then status 201
    And match $[0].amount == 5
    And match $[1].amount == expectedFees

#Get calculation period id
    Given  url baseUrl+'/calculation_periods?annex_id='+annexId
    When method GET
    Then status 200
    And match $.items[0].annex_id == annexId
    * def calculationPeriodId = $.items[0].id

# Create Review Status Update
    Given  url baseUrl+'/review_status_updates'
    And request CreateReviewStatusUpdatePayload
    And set CreateReviewStatusUpdatePayload.calculation_period_id = calculationPeriodId
    When method POST
    Then status 201

 # Verify Review is approved
    Given  url baseUrl+'/notifications/'
    When method GET
    Then status 200
    And match $.items[0].annex_id == annexId
    And match $.items[0].type == "review_approved"

#Approve the calculated fees
    Given  url baseUrl+'/payment_advice'
    And request createPaymentAdvicePayload
    And set createPaymentAdvicePayload.annex_id = annexId
    When method POST
    Then status 201
    * def paymentAdviceId = $.id

#Download Payment Advice PDF
    Given  url baseUrl+'/payment_advice/'+paymentAdviceId+'/pdf'
    When method GET
    Then status 200

    Examples:
      | paymentFrequency | days |
      | Monthly          | 30   |
      | Quarterly        | 90   |
      | AtMaturity       | 365  |