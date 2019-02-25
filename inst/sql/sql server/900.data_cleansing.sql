/******************************************************
Data Cleansing
JM Park

@NHISNSC_rawdata : DB containing NHIS National Sample cohort DB
@NHISNSC_database : DB for NHIS-NSC in CDM format
@NHIS_JK: JK table in NHIS NSC
@NHIS_20T: 20 table in NHIS NSC
@NHIS_30T: 30 table in NHIS NSC
@NHIS_40T: 40 table in NHIS NSC
@NHIS_60T: 60 table in NHIS NSC
@NHIS_GJ: GJ table in NHIS NSC
******************************************************/

/********************************************************
		Delete cases outside of Observation_period
********************************************************/
delete from @NHISNSC_database.VISIT_OCCURRENCE
where visit_occurrence_id not in (
							select visit_occurrence_id
							from @NHISNSC_database.VISIT_OCCURRENCE a, @NHISNSC_database.OBSERVATION_PERIOD b
							where a.person_id=b.person_id
								and (visit_start_date >= observation_period_start_date and observation_period_end_date >= visit_end_date) 
							)

delete from @NHISNSC_database.CONDITION_OCCURRENCE
where condition_occurrence_id not in (
						select condition_occurrence_id
						from @NHISNSC_database.CONDITION_OCCURRENCE a, @NHISNSC_database.OBSERVATION_PERIOD b
						where a.person_id=b.person_id
							and (a.condition_start_date >= b.observation_period_start_date and a.condition_end_date <= b.observation_period_end_date)
							)

delete from @NHISNSC_database.DRUG_EXPOSURE
where drug_exposure_id not in (
							select drug_exposure_id
							from @NHISNSC_database.DRUG_EXPOSURE a, @NHISNSC_database.OBSERVATION_PERIOD b
							where a.person_id=b.person_id
								and (a.drug_exposure_start_date >= b.observation_period_start_date and a.drug_exposure_end_date <= b.observation_period_end_date)
								)

delete from @NHISNSC_database.PROCEDURE_OCCURRENCE
where procedure_occurrence_id not in (
									select procedure_occurrence_id
									from @NHISNSC_database.PROCEDURE_OCCURRENCE a, @NHISNSC_database.OBSERVATION_PERIOD b
									where a.person_id=b.person_id
										and (procedure_date >= observation_period_start_date and procedure_date <= observation_period_end_date)
										)

delete from @NHISNSC_database.DEVICE_EXPOSURE
where device_exposure_id not in (
							select device_exposure_id
							from @NHISNSC_database.DEVICE_EXPOSURE a, @NHISNSC_database.observation_period b
							where a.person_id=b.person_id
								and (a.device_exposure_start_date >= b.observation_period_start_date and a.device_exposure_end_date <= b.observation_period_end_date)
								)

delete from @NHISNSC_database.MEASUREMENT
where measurement_id not in (
						select measurement_id
						from @NHISNSC_database.MEASUREMENT a, @NHISNSC_database.OBSERVATION_PERIOD b
						where a.person_id=b.person_id
							and (a.measurement_date >= b.observation_period_start_date and a.measurement_date <= b.observation_period_end_date)
							)

delete from @NHISNSC_database.PAYER_PLAN_PERIOD a, @NHISNSC_database.OBSERVATION_PERIOD b, @NHISNSC_database.DEATH c
where a.person_id = b.person_id
	and a.person_id = c.person_id
	and (a.payer_plan_period_start_date < observation_period_start_date or payer_plan_period_end_date > observation_period_end_date)


/********************************************************
Update isuues of Person table of which originated from source data
********************************************************/
-- Change the gender_concept_id and gender_source_value from female to male
update @NHISNSC_database.PERSON
set gender_concept_id='8507', gender_source_value=1
where person_id = 95292839