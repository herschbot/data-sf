CREATE OR REPLACE TABLE
  ASR_ANALYTICS AS
WITH 
  PROP AS (
    SELECT
      left("class_code", 3) AS cc3
      , "class_definition"
    FROM
      PROPERTY_CODES
    WHERE
      "class_code" NOT IN ('VCIX', 'TIC5')
  ),
  ALL_ASR AS (
    SELECT
      PROPLOC
      , RP1NBRCDE
      , RP1PRCLID
      , RP1VOLUME
      , RP1CLACDE
      , YRBLT
      , BATHS
      , BEDS
      , ROOMS
      , STOREYNO
      , UNITS
      , ZONE
      , CONSTTYPE
      , DEPTH
      , FRONT
      , SQFT
      , FBA
      , LAREA
      , LOTCODE
      , REPRISDATE
      , RP1TRACDE
      , OWNRPRCNT
      , EXEMPTYPE
      , RP1STACDE
      , RP1EXMVL2
      , RP1EXMVL1
      , ROLLYEAR
      , RECURRSALD
      , RP1FXTVAL
      , RP1IMPVAL
      , RP1LNDVAL
      , RP1PPTVAL
    FROM
      ASR_2017
    UNION
    SELECT
      PROPLOC
      , RP1NBRCDE
      , RP1PRCLID
      , RP1VOLUME
      , RP1CLACDE
      , YRBLT
      , BATHS
      , BEDS
      , ROOMS
      , STOREYNO
      , UNITS
      , ZONE
      , CONSTTYPE
      , DEPTH
      , FRONT
      , SQFT
      , FBA
      , LAREA
      , LOTCODE
      , REPRISDATE
      , RP1TRACDE
      , OWNRPRCNT
      , EXEMPTYPE
      , RP1STACDE
      , RP1EXMVL2
      , RP1EXMVL1
      , ROLLYEAR
      , RECURRSALD
      , RP1FXTVAL
      , RP1IMPVAL
      , RP1LNDVAL
      , RP1PPTVAL
    FROM
      ASR_2018
    UNION
    SELECT
      PROPLOC
      , RP1NBRCDE
      , RP1PRCLID
      , RP1VOLUME
      , RP1CLACDE
      , YRBLT
      , BATHS
      , BEDS
      , ROOMS
      , STOREYNO
      , UNITS
      , ZONE
      , CONSTTYPE
      , DEPTH
      , FRONT
      , SQFT
      , FBA
      , LAREA
      , LOTCODE
      , REPRISDATE
      , RP1TRACDE
      , OWNRPRCNT
      , EXEMPTYPE
      , RP1STACDE
      , RP1EXMVL2
      , RP1EXMVL1
      , ROLLYEAR
      , RECURRSALD
      , RP1FXTVAL
      , RP1IMPVAL
      , RP1LNDVAL
      , RP1PPTVAL
    FROM
      ASR_2019      
  )
SELECT
  PROPLOC AS Property_Location
  , RP1NBRCDE AS Assessor_Neighborhood_Code
  , N."neighborhood" AS Assessor_Neighborhood
  , RP1PRCLID AS Block_and_Lot
  , trim(left(RP1PRCLID, 5)) AS Block
  , right(RP1PRCLID, length(RP1PRCLID) - 5) AS Lot
  , replace(RP1PRCLID,' ') AS Parcel_Number
  , RP1VOLUME AS Volume_Number
  , RP1CLACDE AS Property_Class_Code
  , PROP."class_definition" AS Property_Class_Code_Definition
  , YRBLT::number(4) AS Year_Property_Built
  , BATHS::number(5) AS Number_of_Bathrooms
  , BEDS::number(5) AS Number_of_Bedrooms
  , ROOMS::number(6) AS Number_of_Rooms
  , STOREYNO::number(4) AS Number_of_Stories
  , UNITS::number(5) AS Number_of_Units
  , ZONE AS Zoning_Code
  , CONSTTYPE AS Construction_Type
  , DEPTH::number(11,2) AS Lot_Depth
  , FRONT::number(11,2) AS Lot_Frontage
  , SQFT::number(11,2) AS Property_Area
  , FBA::number(11,2) AS Basement_Area
  , LAREA::number(11,2) AS Lot_Area
  , LOTCODE AS Lot_Code
  , REPRISDATE AS Prior_Sales_Date
  , RP1TRACDE AS Tax_Rate_Area_Code
  , OWNRPRCNT::number(3,2) AS Percent_of_Ownership
  , EXEMPTYPE AS Exemption_Code
  , E."exemption_definition" AS Exemption_Code_Definition
  , RP1STACDE AS Status_Code
  , RP1EXMVL2::number(14,2) AS Misc_Exemption_Value
  , RP1EXMVL1::number(14,2) AS Homeowner_Exemption_Value
  , ROLLYEAR::number(4) AS Closed_Roll_Year
  , RECURRSALD AS Current_Sales_Date
  , RP1FXTVAL::number(14,2) AS Assessed_Fixtures_Value
  , RP1IMPVAL::number(14,2) AS Assessed_Improvement_Value
  , RP1LNDVAL::number(14,2) AS Assessed_Land_Value
  , RP1PPTVAL::number(14,2) AS Assessed_Personal_Property_Value
  , Parcels."analysis_neighborhood" AS Analysis_Neighborhood
  , Parcels."supervisor_district"::varchar(2) AS Supervisor_District
FROM
  ALL_ASR AS A
LEFT JOIN
  EXEMPTION_CODES AS E
ON
  iff(left(A.EXEMPTYPE, 1) = '0', substr(A.EXEMPTYPE, 2), A.EXEMPTYPE) = E."exemption_code"
LEFT JOIN
  PROP
ON
  A.RP1CLACDE = PROP.cc3
LEFT JOIN
  NEIGHBORHOOD_CODES AS N
ON
  iff(left(A.RP1NBRCDE, 1) = '0', substr(A.RP1NBRCDE, 2), A.RP1NBRCDE) = N."code"
LEFT JOIN
  PARCELS AS Parcels
ON
  replace(A.RP1PRCLID,' ') = Parcels."parcel_number"
;

UPDATE TABLE
  ASR_ANALYTICS
SET
  Property_Class_Code_Definition = 'TIC Bldg 14 units or less'
WHERE
  Property_Class_Code = 'TIC'
;