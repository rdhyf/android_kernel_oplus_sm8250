#ifndef _BINDER_INTERNAL_VENDOR_H
#define _BINDER_INTERNAL_VENDOR_H

#include "binder_internal.h"

// struct binder_work {
// 	struct list_head entry;

// 	enum binder_work_type {
// 		BINDER_WORK_TRANSACTION = 1,
// 		BINDER_WORK_TRANSACTION_COMPLETE,
// 		BINDER_WORK_RETURN_ERROR,
// 		BINDER_WORK_NODE,
// 		BINDER_WORK_DEAD_BINDER,
// 		BINDER_WORK_DEAD_BINDER_AND_CLEAR,
// 		BINDER_WORK_CLEAR_DEATH_NOTIFICATION,
// 	} type;
// #ifdef CONFIG_OPLUS_BINDER_STRATEGY
// 	u64 ob_begin;
// #endif
// };


// struct binder_priority {
// 	unsigned int sched_policy;
// 	int prio;
// };



struct binder_transaction {
	int debug_id;
	struct binder_work work;
	struct binder_thread *from;
	struct binder_transaction *from_parent;
	struct binder_proc *to_proc;
	struct binder_thread *to_thread;
	struct binder_transaction *to_parent;
	unsigned need_reply:1;

	struct binder_buffer *buffer;
	unsigned int code;
	unsigned int flags;
	struct binder_priority priority;
	struct binder_priority saved_priority;
	bool set_priority_called;
	kuid_t sender_euid;
	binder_uintptr_t security_ctx;

	spinlock_t lock;

#if defined(CONFIG_OPLUS_FEATURE_ASYNC_BINDER_INHERIT_UX)
	int async_ux_enable;
#endif
};

#endif

