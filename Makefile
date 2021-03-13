.PHONY:= create_job delete_all_jobs run dep-all
CLUSTER := $(shell yq e ".cluster_name" settings.yaml)
MCC_PID_DIR := mcc-pid
PIDS := $(shell find $(MCC_PID_DIR) -name '*.pid' )

run-all-mcc-pid/%.pid: wait-mcc-pid/%.pid  deploy-mcc-pid/%.pid wait-dep-mcc-pid/%.pid install-mcc-pid/%.pid alias-mcc-pid/%.pid
	@echo "done"
run:
	$(eval JOBID = $(shell mcc job add ${CLUSTER} 2 for 2h now))
	touch ${MCC_PID_DIR}/${JOBID}.pid
	$(MAKE) run-all-mcc-pid/${JOBID}.pid

dep-all:
	for pid in ${PIDS}; do\
	   $(MAKE) deploy-$$pid;\
	   $(MAKE) wait-dep-$$pid;\
	   $(MAKE) install-$$pid;\
	done
	

create_job: 
	$(eval JOBID = $(shell mcc job add ${CLUSTER} 2 for 2h now))
	touch ${MCC_PID_DIR}/${JOBID}.pid
	
wait-mcc-pid/%.pid: 
	$(eval JOBID = $(basename $(@F)))
	mcc job wait ${JOBID}

del-mcc-pid/%.pid: 
	$(eval JOBID = $(basename $(@F)))
	mcc job del ${JOBID}

deploy-mcc-pid/%.pid: 
	$(eval JOBID = $(basename $(@F)))
	$(eval DEPID = $(shell mcc dep add ${JOBID}))
	@echo "${DEPID}" > ${MCC_PID_DIR}/${JOBID}.pid

wait-dep-mcc-pid/%.pid:
	$(eval JOBID = $(basename $(@F)))
	@echo ${MCC_PID_DIR}/${JOBID}.pid
	$(eval DEPID = $(shell cat ${MCC_PID_DIR}/${JOBID}.pid))
	mcc dep wait ${DEPID}

alias-mcc-pid/%.pid:
	$(eval JOBID = $(basename $(@F)))
	mcc alias list "${JOBID}" > mcc-pid/${JOBID}.alias


install-mcc-pid/%.pid: 
	$(eval JOBID = $(basename $(@F)))
	mcc job install "${JOBID}" salt

delete_all_jobs: 
	$(eval JOBIDS = $(shell mcc job list --filter state=running|yq e ".uid" -))
	mcc job del ${JOBIDS}|true

	for pid in ${PIDS}; do\
		mcc job del $$pid|true;\
		rm -rf $$pid;\
	done


	

	
