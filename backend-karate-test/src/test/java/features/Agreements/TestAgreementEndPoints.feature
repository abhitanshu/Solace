@Exposure @Agreement @Platform
Feature: Test Agreement/Exposure Endpoints

  Background:
    * call read('classpath:features/common/Background.feature')

  Scenario: Verify Create, Update, Delete and Get Endpoints for Exposure
    #Create Obligor
    * call read('classpath:features/common/CreateObligor.feature')

    # Create Exposure
    Given  url baseUrl+'/exposures'
    And request createAgreementPayload
    And set createAgreementPayload.obligorId = obligorId
    When method POST
    Then status 201
    * def exposureId = $.id

##    Uncomment below after implementation of https://dev.azure.com/raboweb/WR%20Innovation/_sprints/taskboard/Project%20Solace/WR%20Innovation/Sprint%20175?workitem=13080694
  # Update Exposure - Update one field of each data type
#    Given  url baseUrl+'/exposures/'+exposureId
#    * set createAgreementPayload.startDate = '2024-12-27'
#    * set createAgreementPayload.beneficiary = 'beneficiary_updated'
#    * set createAgreementPayload.grossAmount = 200000
#    * set createAgreementPayload.obligorId = obligorId
#    And request createAgreementPayload
#    When method PUT
#    Then status 200
#    And match response.startDate == '2024-12-27'
#    And match response.beneficiary == 'beneficiary_updated'
#    And match response.grossAmount == 200000

   # Read Exposure
    Given  url baseUrl+'/exposures/'+exposureId
    When method GET
    Then status 200
    And match response.status == 'ACTIVE'

    # Delete exposure
    Given  url baseUrl+'/exposures/'+exposureId
    And request {"status": "CLOSED"}
    When method PATCH
    Then status 200

    # Read Exposure
    Given  url baseUrl+'/exposures/'+exposureId
    When method GET
    Then status 200
    And match response.status == 'CLOSED'

  # Validations
#  1. Initial net commitment can not be more than transaction amount plus tolerence
#  2. All the Transaction detail fields are mandatory - goods, ports,exporter, importer, currency
#  3. Tenor - Only enabled for LC's with transaction types Sight LC and Deferred Payment LC. Hide field for Guarantee and for LC > Standby LC.
#  4. Latest Shipment date - Mandatory for LC's with transaction types Sight LC and Deferred Payment LC. Optional for Guarantee and for LC > Standby LC.
#  5. Maturity date - Mandatory for LC's with transaction types Sight LC and Deferred Payment LC. Optional for Guarantee and for LC > Standby LC.

  Scenario: Latest Shipment date cannot be before LC Issue Date
    #Create Obligor
    * call read('classpath:features/common/CreateObligor.feature')
    Given  url baseUrl+'/exposures'
    And request createAgreementPayload
    And set createAgreementPayload.obligorId = obligorId
    And set createAgreementPayload.lcIssuanceDate = "2025-06-23"
    And set createAgreementPayload.latestShipmentDate = "2025-06-22"
    When method POST
    Then status 400
    And match $.messageDescription == "Latest shipment date cannot be before LC issuance date."

  Scenario: Maturity Date can't be before today's date
    #Create Obligor
    * call read('classpath:features/common/CreateObligor.feature')
    Given  url baseUrl+'/exposures'
    * def maturityDate = testUtil.getDateAfterDaysfromCurrentDate(-1)
    And request createAgreementPayload
    And set createAgreementPayload.obligorId = obligorId
    And set createAgreementPayload.lcIssuanceDate = "2025-06-23"
    And set createAgreementPayload.latestShipmentDate = "2025-06-25"
    And set createAgreementPayload.maturityDate = maturityDate
    When method POST
    Then status 400
    And match $.messageDescription == "Maturity date cannot be in the past."

  Scenario: Maturity Date can't be before Latest Shipment Date
    #Create Obligor
    * call read('classpath:features/common/CreateObligor.feature')
    Given  url baseUrl+'/exposures'
    * def latestShipmentDate = testUtil.getDateAfterDaysfromCurrentDate(5)
    * def maturityDate = testUtil.getDateAfterDaysfromCurrentDate(3)
    And request createAgreementPayload
    And set createAgreementPayload.obligorId = obligorId
    And set createAgreementPayload.lcIssuanceDate = "2025-06-23"
    And set createAgreementPayload.latestShipmentDate = latestShipmentDate
    And set createAgreementPayload.maturityDate = maturityDate
    When method POST
    Then status 400
    And match $.messageDescription == "Maturity date cannot be before or same as latest shipment date."

  Scenario: Initial net commitment can not be more than transaction amount plus tolerence
    #Create Obligor
    * call read('classpath:features/common/CreateObligor.feature')
    Given  url baseUrl+'/exposures'
    And request createAgreementPayload
    And set createAgreementPayload.obligorId = obligorId
    And set createAgreementPayload.lcAmount = 100
    And set createAgreementPayload.toleranceUpperLimit = 5
    And set createAgreementPayload.initialNetCommitment = 105.01
    When method POST
    Then status 400
    And match $.messageDescription == "Initial net commitment cannot be greater than transaction amount with tolerance upper limit."

  Scenario Outline: Tenor, Latest Shipment Date and Maturity Date are Mandatory for LC's with transaction types Sight LC and Deferred Payment LC
  # Negative scenarios if various fields are NULL
    #Create Obligor
    * call read('classpath:features/common/CreateObligor.feature')
    Given  url baseUrl+'/exposures'
    And request createAgreementPayload
    And set createAgreementPayload.obligorId = obligorId
    And set createAgreementPayload.exposureType = <ExposureType>
    And set createAgreementPayload.transactionType = <TransactionType>
    And set createAgreementPayload.tenor = <Tenor>
    And set createAgreementPayload.latestShipmentDate = <LatestShipmentDate>
    And set createAgreementPayload.maturityDate = <MaturityDate>
    When method POST
    Then status 400
    And match $.messageDescription == <MessageDescription>
    Examples:
      | ExposureType       | TransactionType       | Tenor                   | LatestShipmentDate | MaturityDate | MessageDescription                                                                        |
      | "LETTER_OF_CREDIT" | "SIGHT_LC"            | null                    | "2025-11-27"       | "2026-11-27" | "Tenor is required for Sight LC or Deferred Payment LC transaction types."                |
      | "LETTER_OF_CREDIT" | "DEFERRED_PAYMENT_LC" | null                    | "2025-11-27"       | "2026-11-27" | "Tenor is required for Sight LC or Deferred Payment LC transaction types."                |
      | "LETTER_OF_CREDIT" | "SIGHT_LC"            | "45 days from shipping" | null               | "2026-11-27" | "Latest shipment date is required for Sight LC or Deferred Payment LC transaction types." |
      | "LETTER_OF_CREDIT" | "DEFERRED_PAYMENT_LC" | "45 days from shipping" | null               | "2026-11-27" | "Latest shipment date is required for Sight LC or Deferred Payment LC transaction types." |
      | "LETTER_OF_CREDIT" | "SIGHT_LC"            | "45 days from shipping" | "2025-11-27"       | null         | "Maturity date is required for Sight LC or Deferred Payment LC transaction types."        |
      | "LETTER_OF_CREDIT" | "DEFERRED_PAYMENT_LC" | "45 days from shippin " | "2025-11-27"       | null         | "Maturity date is required for Sight LC or Deferred Payment LC transaction types."        |
      | "LETTER_OF_CREDIT" | null                  | "45 days from shippin " | "2025-11-27"       | "2026-11-27" | "Transaction type is required for Letter of Credit exposure type."                        |


  Scenario Outline: Tenor, Latest Shipment Date and Maturity Date are Optional for Guarantee and Stand By LC
  # For Stand By LC and Guarantee these fields shouldn't have any impact
    #Create Obligor
    * call read('classpath:features/common/CreateObligor.feature')
    Given  url baseUrl+'/exposures'
    And request createAgreementPayload
    And set createAgreementPayload.obligorId = obligorId
    And set createAgreementPayload.exposureType = <ExposureType>
    And set createAgreementPayload.transactionType = <TransactionType>
    And set createAgreementPayload.tenor = <Tenor>
    And set createAgreementPayload.latestShipmentDate = <LatestShipmentDate>
    And set createAgreementPayload.maturityDate = <MaturityDate>
    When method POST
    Then status 201
    Examples:
      | ExposureType       | TransactionType | Tenor | LatestShipmentDate | MaturityDate |
      | "LETTER_OF_CREDIT" | "STANDBY_LC"    | null  | null               | null         |
      | "GUARANTEE"        | null            | null  | null               | null         |

  Scenario Outline: Check all the mandatory fields, Checked field - <field>
    #Create Obligor
    * call read('classpath:features/common/CreateObligor.feature')
    Given  url baseUrl+'/exposures'
    And request createAgreementPayload
    And set createAgreementPayload.obligorId = obligorId
    And set createAgreementPayload.<field> = null
    When method POST
    Then status 400
    And match $.subErrors[0].field == "<field>"
    And match $.subErrors[0].message == "This field is required"
    Examples:
      | field                     |
      | goods                     |
      | exporter                  |
      | importer                  |
      | portOfLoading             |
      | portOfDischarge           |
      | contractId                |
      | exposureType              |
      | lcAmount                  |
      | currency                  |
      | lcIssuanceDate            |
      | insured                   |
      | toleranceLowerLimit       |
      | toleranceUpperLimit       |
      | initialNetCommitment      |
      | dealType                  |
      | originalFee.type          |
      | originalFee.structureType |
      | originalFee.value         |