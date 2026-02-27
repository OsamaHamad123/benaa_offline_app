 Mobile Code Reservation System
IMPLEMENTED ▼
Overview
Mobile Code Reservation System - supports Offline-First operation with automatic synchronization. Each device can obtain up to 5000 unused codes.

⚠️ Important: 4 Tables Verification
The algorithm checks for code uniqueness across 4 tables:

#	Table	Column	Description
1	data	file_id_number	Main file records
2	sponsorships	internal_file_number	Sponsorship records
3	dead_people	re_file_id	Deceased people records
4	reserved_codes	code	Reserved codes
📋 Limits & Constraints
Constant	Value	Description
MAX_UNUSED_CODES_PER_DEVICE	5000	Maximum unused codes per device
DEFAULT_BATCH_SIZE	5000	Default batch size
BATCH_EXPIRY_DAYS	30	Batch expiry in days
MIN_BATCH_SIZE	100	Minimum batch size
MAX_BATCH_SIZE	10000	Maximum batch size
📋 Complete Workflow Scenario
[Admin] Create batch of codes: POST /batch/create
[User] Login from mobile device
[App] Login sync: POST /login-sync → Receives up to 5000 codes
[App] Work Offline - Use local codes
[App] When online: POST /confirm-usage → Confirm used codes
[Optional] Request additional codes: POST /request-codes
📊 UML Diagrams - Complete Flow Charts
1️⃣ Login & Initial Sync Flow

┌─────────────────────────────────────────────────────────────────────┐
│                    LOGIN & INITIAL SYNC FLOW                        │
└─────────────────────────────────────────────────────────────────────┘

    ┌──────┐         ┌──────────┐         ┌──────────┐         ┌──────┐
    │ USER │         │   APP    │         │ LOCAL DB │         │  API │
    └──┬───┘         └────┬─────┘         └────┬─────┘         └──┬───┘
       │                  │                    │                  │
       │  Open App        │                    │                  │
       │─────────────────>│                    │                  │
       │                  │                    │                  │
       │                  │  Check Token       │                  │
       │                  │───────────────────>│                  │
       │                  │                    │                  │
       │                  │<───────────────────│                  │
       │                  │  Token Status      │                  │
       │                  │                    │                  │
       │                  │                    │                  │
   ╔═══╧══════════════════╧════════════════════╧══════════════════╧═══╗
   ║  IF TOKEN VALID:                                                 ║
   ║     → Show Home Screen                                           ║
   ║                                                                  ║
   ║  IF TOKEN EXPIRED:                                               ║
   ╚══════════════════════════════════════════════════════════════════╝
       │                  │                    │                  │
       │  Enter Login     │                    │                  │
       │─────────────────>│                    │                  │
       │                  │                    │                  │
       │                  │  POST /auth/login  │                  │
       │                  │───────────────────────────────────────>│
       │                  │                    │                  │
       │                  │<───────────────────────────────────────│
       │                  │  Token + User Data │                  │
       │                  │                    │                  │
       │                  │  Save Token        │                  │
       │                  │───────────────────>│                  │
       │                  │                    │                  │
       │                  │                    │                  │
   ╔═══╧══════════════════╧════════════════════╧══════════════════╧═══╗
   ║  ⭐ LOGIN SYNC STARTS HERE                                       ║
   ╚══════════════════════════════════════════════════════════════════╝
       │                  │                    │                  │
       │                  │  Get Local Codes   │                  │
       │                  │───────────────────>│                  │
       │                  │                    │                  │
       │                  │<───────────────────│                  │
       │                  │  Codes List        │                  │
       │                  │                    │                  │
       │                  │  POST /login-sync  │                  │
       │                  │───────────────────────────────────────>│
       │                  │                    │                  │
       │                  │<───────────────────────────────────────│
       │                  │  New Codes (max 5000)                 │
       │                  │                    │                  │
       │                  │  Save New Codes    │                  │
       │                  │───────────────────>│                  │
       │                  │                    │                  │
       │  Home Screen     │                    │                  │
       │<─────────────────│                    │                  │
       │                  │                    │                  │
    ┌──┴───┐         ┌────┴─────┐         ┌────┴─────┐         ┌──┴───┐
    │ USER │         │   APP    │         │ LOCAL DB │         │  API │
    └──────┘         └──────────┘         └──────────┘         └──────┘
            
2️⃣ Offline Code Usage Flow

┌─────────────────────────────────────────────────────────────────────┐
│                    OFFLINE CODE USAGE FLOW                          │
└─────────────────────────────────────────────────────────────────────┘

                      ┌─────────────────────┐
                      │  User Creates       │
                      │  New Record         │
                      └──────────┬──────────┘
                                 │
                                 ▼
                      ┌─────────────────────┐
                      │  Check Internet     │
                      │  Connection         │
                      └──────────┬──────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │ NO (Offline)     │                  │ YES (Online)
              ▼                  │                  ▼
    ┌─────────────────────┐      │      ┌─────────────────────┐
    │  Get First Unused   │      │      │  Direct API Call    │
    │  Code from LocalDB  │      │      │  POST /data/create  │
    └──────────┬──────────┘      │      └──────────┬──────────┘
               │                 │                 │
               ▼                 │                 │
    ┌─────────────────────┐      │                 │
    │  Has Available      │      │                 │
    │  Code?              │      │                 │
    └──────────┬──────────┘      │                 │
               │                 │                 │
        ┌──────┴──────┐          │                 │
        │ YES         │ NO       │                 │
        ▼             ▼          │                 │
┌───────────────┐ ┌───────────────┐                │
│ Assign Code   │ │ ❌ ERROR      │                │
│ to Record     │ │ No codes!     │                │
└───────┬───────┘ │ Connect to    │                │
        │         │ internet      │                │
        ▼         └───────────────┘                │
┌───────────────┐                                  │
│ Mark Code as  │                                  │
│ Used in       │                                  │
│ LocalDB       │                                  │
│ synced=0      │                                  │
└───────┬───────┘                                  │
        │                                          │
        ▼                                          │
┌───────────────┐                                  │
│ ✅ SUCCESS    │<─────────────────────────────────┘
│ Record Saved  │
│ Locally       │
└───────────────┘
            
3️⃣ Online Sync & Code Confirmation Flow

┌─────────────────────────────────────────────────────────────────────┐
│                 ONLINE SYNC & CODE CONFIRMATION                     │
└─────────────────────────────────────────────────────────────────────┘

    ┌──────────┐         ┌──────────┐         ┌──────────┐         ┌──────────┐
    │   APP    │         │ LOCAL DB │         │   API    │         │ 4 TABLES │
    └────┬─────┘         └────┬─────┘         └────┬─────┘         └────┬─────┘
         │                    │                    │                    │
         │  App Detects Online │                   │                    │
         │  Connection         │                   │                    │
         │                    │                    │                    │
         │  Get Unsynced Codes │                   │                    │
         │  (synced=0, used=1) │                   │                    │
         │───────────────────>│                    │                    │
         │                    │                    │                    │
         │<───────────────────│                    │                    │
         │  Codes List         │                   │                    │
         │                    │                    │                    │
         │  POST /confirm-usage                    │                    │
         │  {device_id, codes[]}                   │                    │
         │────────────────────────────────────────>│                    │
         │                    │                    │                    │
         │                    │                    │  Verify Each Code  │
         │                    │                    │───────────────────>│
         │                    │                    │                    │
         │                    │                    │<───────────────────│
         │                    │                    │  Valid / Conflicts │
         │                    │                    │                    │
   ╔═════╧════════════════════╧════════════════════╧════════════════════╧═════╗
   ║  FOR EACH CODE:                                                          ║
   ║    • Valid & No Conflict  → Mark as used, update device_id              ║
   ║    • Conflict (Used by another) → Add to conflicts[]                    ║
   ║    • Not Found → Add to not_found[]                                     ║
   ╚══════════════════════════════════════════════════════════════════════════╝
         │                    │                    │                    │
         │<────────────────────────────────────────│                    │
         │  {confirmed[], conflicts[], not_found[]}│                    │
         │                    │                    │                    │
         │  UPDATE synced=1   │                    │                    │
         │  for confirmed codes                    │                    │
         │───────────────────>│                    │                    │
         │                    │                    │                    │
         │  Handle Conflicts   │                   │                    │
         │  (show warning)     │                   │                    │
         │                    │                    │                    │
    ┌────┴─────┐         ┌────┴─────┐         ┌────┴─────┐         ┌────┴─────┐
    │   APP    │         │ LOCAL DB │         │   API    │         │ 4 TABLES │
    └──────────┘         └──────────┘         └──────────┘         └──────────┘
            
4️⃣ Code Balance Check & Refill Flow

┌─────────────────────────────────────────────────────────────────────┐
│                  CODE BALANCE CHECK & REFILL                        │
└─────────────────────────────────────────────────────────────────────┘

                      ┌─────────────────────┐
                      │  Periodic Balance   │
                      │  Check Triggered    │
                      └──────────┬──────────┘
                                 │
                                 ▼
                      ┌─────────────────────┐
                      │  Is Device Online?  │
                      └──────────┬──────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │ NO               │                  │ YES
              ▼                  │                  ▼
    ┌─────────────────────┐      │      ┌─────────────────────┐
    │  Skip Check         │      │      │  GET /device-stats  │
    │  Wait for Internet  │      │      │  Get current count  │
    └─────────────────────┘      │      └──────────┬──────────┘
                                 │                 │
                                 │                 ▼
                                 │      ┌─────────────────────┐
                                 │      │  Unused Codes < 100?│
                                 │      └──────────┬──────────┘
                                 │                 │
                                 │      ┌──────────┴──────────┐
                                 │      │ NO                  │ YES
                                 │      ▼                     ▼
                                 │ ┌───────────────┐  ┌───────────────┐
                                 │ │ Balance OK    │  │ Can Request   │
                                 │ │ No action     │  │ More? (< 5000)│
                                 │ └───────────────┘  └───────┬───────┘
                                 │                            │
                                 │                 ┌──────────┴──────────┐
                                 │                 │ NO                  │ YES
                                 │                 ▼                     ▼
                                 │      ┌───────────────┐  ┌───────────────┐
                                 │      │ ⚠️ WARNING    │  │ POST          │
                                 │      │ At 5000 limit │  │ /request-codes│
                                 │      │ Use existing  │  │ {count: 500}  │
                                 │      └───────────────┘  └───────┬───────┘
                                 │                                 │
                                 │                                 ▼
                                 │                      ┌───────────────┐
                                 │                      │ Save New      │
                                 │                      │ Codes to      │
                                 │                      │ LocalDB       │
                                 │                      └───────┬───────┘
                                 │                              │
                                 │                              ▼
                                 │                      ┌───────────────┐
                                 │                      │ ✅ Notify     │
                                 │                      │ User: Codes   │
                                 │                      │ Refilled!     │
                                 │                      └───────────────┘
            
5️⃣ Code Lifecycle State Diagram

┌─────────────────────────────────────────────────────────────────────┐
│                     CODE LIFECYCLE STATES                           │
└─────────────────────────────────────────────────────────────────────┘


    ╔═══════════════════════════════════════════════════════════════╗
    ║                     CODE STATE TRANSITIONS                     ║
    ╚═══════════════════════════════════════════════════════════════╝


    ┌───────────────┐       Device Sync         ┌───────────────┐
    │   GENERATED   │ ─────────────────────────>│   ASSIGNED    │
    │               │   (login-sync or          │               │
    │ Admin creates │    request-codes)         │ is_used=0     │
    │ batch of codes│                           │ synced=0      │
    └───────┬───────┘                           └───────┬───────┘
            │                                           │
            │ 30 days                          ┌────────┴────────┐
            │ expired                          │                 │
            ▼                                  ▼                 ▼
    ┌───────────────┐                  ┌───────────────┐ ┌───────────────┐
    │   EXPIRED     │                  │ USED OFFLINE  │ │ USED ONLINE   │
    │               │                  │               │ │               │
    │ Batch expired │                  │ is_used=1     │ │ is_used=1     │
    │ Cannot use    │                  │ synced=0      │ │ synced=1      │
    └───────────────┘                  └───────┬───────┘ └───────┬───────┘
                                               │                 │
                                               │ Online Sync     │
                                               │ (confirm-usage) │ Direct
                                               ▼                 │
                                       ┌───────────────┐         │
                                       │  CONFIRMED    │<────────┘
                                       │               │
                                       │ is_used=1     │
                                       │ synced=1      │
                                       │               │
                                       │ ✅ COMPLETE   │
                                       └───────────────┘
            
6️⃣ Complete System Architecture

┌─────────────────────────────────────────────────────────────────────┐
│                  COMPLETE SYSTEM ARCHITECTURE                       │
└─────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────┐
│                              MOBILE APPLICATION                             │
│                                                                             │
│    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                   │
│    │     UI      │    │  Sync       │    │   Code      │                   │
│    │  Interface  │    │  Engine     │    │  Manager    │                   │
│    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘                   │
│           │                  │                  │                          │
│           └──────────────────┼──────────────────┘                          │
│                              │                                             │
│                              ▼                                             │
│                    ┌─────────────────────┐                                 │
│                    │    SQLite Database   │                                │
│                    │  (Local Storage)     │                                │
│                    │  • reserved_codes    │                                │
│                    │  • pending_records   │                                │
│                    └─────────────────────┘                                 │
└─────────────────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS / REST API
                              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                               API SERVER                                    │
│                                                                             │
│    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐       │
│    │  Authentication │    │  Code           │    │  Data           │       │
│    │  Service        │    │  Reservation    │    │  Sync           │       │
│    │  /auth/*        │    │  /codes/*       │    │  /data/*        │       │
│    └────────┬────────┘    └────────┬────────┘    └────────┬────────┘       │
│             │                      │                      │                 │
│             └──────────────────────┼──────────────────────┘                 │
│                                    │                                        │
│                                    ▼                                        │
│                    ┌───────────────────────────────┐                        │
│                    │      VERIFICATION SYSTEM      │                        │
│                    │  ┌─────────────────────────┐  │                        │
│                    │  │ Uniqueness Algorithm    │  │                        │
│                    │  │ findSmallestGap()       │  │                        │
│                    │  │ generateUniqueCode()    │  │                        │
│                    │  └─────────────────────────┘  │                        │
│                    └───────────────┬───────────────┘                        │
│                                    │                                        │
└────────────────────────────────────┼────────────────────────────────────────┘
                                     │
                                     │ Checks 4 Tables
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            SERVER DATABASE                                  │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │ data            │  │ sponsorships    │  │ dead_people     │             │
│  │ ├─file_id_number│  │ ├─internal_file │  │ ├─re_file_id    │             │
│  │ ├─name          │  │ │  _number      │  │ ├─name          │             │
│  │ └─...           │  │ └─...           │  │ └─...           │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │ reserved_codes  │  │ code_batches    │  │ users           │             │
│  │ ├─code          │  │ ├─batch_name    │  │ ├─id            │             │
│  │ ├─batch_id      │  │ ├─size          │  │ ├─email         │             │
│  │ ├─device_id     │  │ ├─expires_at    │  │ └─...           │             │
│  │ ├─is_used       │  │ └─...           │  │                 │             │
│  │ └─used_at       │  │                 │  │                 │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
            
⭐ Login Sync - Most Important!
POST
/api/mobile/codes/login-sync
⭐⭐⭐ Very Important: This endpoint must be called immediately after successful login. It synchronizes offline used codes and assigns new codes to the device (up to 5000).
Request Body
Parameter	Type	Required	Description
device_id	string	Yes	Unique device identifier (UUID)
device_codes	array	No	Codes stored on device with their status
device_codes.*.code	string	Yes	The code
device_codes.*.used	boolean	Yes	Is it used?
device_codes.*.used_at	datetime	No	Usage timestamp
device_codes.*.record_id	string	No	Associated record ID
Request Example
{
    "device_id": "DEVICE-UUID-12345",
    "device_codes": [
        {
            "code": "003139",
            "used": true,
            "used_at": "2026-01-06T10:30:00Z",
            "record_id": "12345"
        },
        {
            "code": "003140",
            "used": false
        }
    ]
}
Success Response (200 OK)
{
    "success": true,
    "message": "Synchronization successful",
    "data": {
        "sync_result": {
            "confirmed_used": ["003139"],
            "confirmed_used_count": 1,
            "already_confirmed": [],
            "already_confirmed_count": 0,
            "invalid_codes": [],
            "invalid_codes_count": 0,
            "conflict_codes": [],
            "conflict_codes_count": 0
        },
        "new_codes": ["003250", "003251", "003252", "..."],
        "new_codes_count": 4999,
        "device_stats": {
            "device_id": "DEVICE-UUID-12345",
            "total_assigned": 5000,
            "used_count": 1,
            "unused_count": 4999,
            "max_allowed": 5000,
            "can_request_more": false,
            "available_slots": 0
        }
    }
}
Sync Result Explanation
Field	Description
confirmed_used	Codes successfully confirmed as used
already_confirmed	Codes already confirmed from same device
invalid_codes	Invalid codes (not found or not for mobile)
conflict_codes	Codes used by another device (conflict!)
new_codes	New codes assigned to device
POST
/api/mobile/codes/confirm-usage
Description: Confirm usage of specific codes. Use this endpoint to confirm codes used offline when coming online.
Request Body
Parameter	Type	Required	Description
device_id	string	Yes	Device identifier
codes	array	Yes	List of codes (1-500)
codes.*.code	string	Yes	The code
codes.*.used_at	datetime	No	Usage timestamp
codes.*.record_type	string	No	Record type: data, sponsorship, dead_people
codes.*.record_id	integer	No	Record ID
Request Example
{
    "device_id": "DEVICE-UUID-12345",
    "codes": [
        {
            "code": "003145",
            "used_at": "2026-01-06T11:00:00Z",
            "record_type": "data",
            "record_id": 567
        },
        {
            "code": "003146",
            "used_at": "2026-01-06T11:05:00Z",
            "record_type": "sponsorship",
            "record_id": 89
        }
    ]
}
Success Response (200 OK)
{
    "success": true,
    "message": "Code usage confirmed",
    "data": {
        "confirmed": ["003145", "003146"],
        "confirmed_count": 2,
        "already_used": [],
        "already_used_count": 0,
        "not_found": [],
        "not_found_count": 0,
        "conflicts": [],
        "conflicts_count": 0
    }
}
POST
/api/mobile/codes/request-codes
Description: Request new codes for the device. Use this endpoint when the device needs additional codes.
Request Body
Parameter	Type	Required	Description
device_id	string	Yes	Device identifier
count	integer	No	Number of codes requested (1-5000)
Request Example
{
    "device_id": "DEVICE-UUID-12345",
    "count": 500
}
Success Response (200 OK)
{
    "success": true,
    "message": "Codes assigned successfully",
    "data": {
        "codes": ["003300", "003301", "003302", "..."],
        "assigned_count": 500,
        "device_stats": {
            "device_id": "DEVICE-UUID-12345",
            "total_assigned": 5000,
            "used_count": 100,
            "unused_count": 4900,
            "max_allowed": 5000,
            "can_request_more": true,
            "available_slots": 100
        }
    }
}
Error Response - Limit Reached (400 Bad Request)
{
    "success": false,
    "error": "limit_reached",
    "message": "Maximum unused codes limit reached (5000)",
    "data": {
        "current_unused": 5000,
        "max_allowed": 5000
    }
}
Error Response - No Codes Available (404 Not Found)
{
    "success": false,
    "error": "no_codes_available",
    "message": "No codes available, please create a new batch"
}
GET
/api/mobile/codes/device-stats
Description: Get statistics for a specific device.
Query Parameters
Parameter	Type	Required	Description
device_id	string	Yes	Device identifier
Request Example
GET /api/mobile/codes/device-stats?device_id=DEVICE-UUID-12345
Success Response (200 OK)
{
    "success": true,
    "data": {
        "device_id": "DEVICE-UUID-12345",
        "total_assigned": 5000,
        "used_count": 150,
        "unused_count": 4850,
        "max_allowed": 5000,
        "can_request_more": true,
        "available_slots": 150
    }
}
📦 Batch Management
POST
/api/mobile/codes/batch/create
Description: Create a new batch of codes (Admin only). Codes are generated in 6-digit format (e.g., 003139).
Request Body
Parameter	Type	Required	Description
batch_size	integer	No	Batch size (100-10000), default: 5000
Request Example
{
    "batch_size": 5000
}
Success Response (201 Created)
{
    "success": true,
    "message": "Successfully created new batch of 5000 codes",
    "data": {
        "batch": {
            "id": 1,
            "batch_size": 5000,
            "code_prefix": "",
            "start_number": 3139,
            "end_number": 8138,
            "total_codes": 5000,
            "used_count": 0,
            "available_count": 5000,
            "usage_percentage": 0,
            "status": "active",
            "expires_at": "2026-02-05T14:00:00.000000Z",
            "is_expired": false,
            "created_at": "2026-01-06T14:00:00.000000Z"
        },
        "generated_count": 5000,
        "failed_count": 0,
        "sample_codes": ["003139", "003140", "003141", "003142", "003143"]
    }
}
GET
/api/mobile/codes/batch/active
Get the current active batch.
Success Response (200 OK)
{
    "success": true,
    "data": {
        "batch": {
            "id": 1,
            "batch_size": 5000,
            "total_codes": 5000,
            "used_count": 150,
            "available_count": 4850,
            "usage_percentage": 3,
            "status": "active",
            "expires_at": "2026-02-05T14:00:00.000000Z",
            "is_expired": false
        }
    }
}
Error Response (404 Not Found)
{
    "success": false,
    "error": "no_active_batch",
    "message": "No active batch found, please create a new batch"
}
GET
/api/mobile/codes/batches
List all batches with pagination.
Query Parameters
Parameter	Type	Required	Description
per_page	integer	No	Results per page (max: 100)
🔢 Code Operations
GET
/api/mobile/codes/available
Description: Get list of available codes for use.
Query Parameters
Parameter	Type	Required	Description
count	integer	No	Number of codes requested (1-500), default: 100
batch_id	integer	No	Specific batch ID
Success Response (200 OK)
{
    "success": true,
    "data": {
        "codes": [
            {"id": 1, "code": "003139", "batch_id": 1, "expires_at": "2026-02-05T14:00:00.000000Z"},
            {"id": 2, "code": "003140", "batch_id": 1, "expires_at": "2026-02-05T14:00:00.000000Z"}
        ],
        "count": 2,
        "stats": {
            "total_available": 4998,
            "total_used": 2
        }
    }
}
POST
/api/mobile/codes/check
Description: Check the status of specific codes (used/available).
Request Body
{
    "codes": ["003139", "003140", "999999"]
}
Success Response (200 OK)
{
    "success": true,
    "data": {
        "results": {
            "003139": {
                "exists": true,
                "used": true,
                "used_at": "2026-01-06T10:30:00.000000Z",
                "device_id": "DEVICE-001",
                "synced": true
            },
            "003140": {
                "exists": true,
                "used": false,
                "used_at": null,
                "device_id": null,
                "synced": false
            },
            "999999": {
                "exists": false,
                "used": false,
                "used_at": null,
                "device_id": null,
                "synced": false
            }
        },
        "checked_count": 3,
        "found_count": 2,
        "used_count": 1,
        "available_count": 1
    }
}
POST
/api/mobile/codes/sync
Description: Synchronize used codes from mobile device to server.
Request Body
{
    "device_id": "DEVICE-UUID-12345",
    "used_codes": [
        {"code": "003139", "used_at": "2026-01-06T09:00:00Z", "notes": "تسجيل يتيم"},
        {"code": "003140", "used_at": "2026-01-06T09:15:00Z"}
    ]
}
Success Response (200 OK)
{
    "success": true,
    "message": "Codes synchronized successfully",
    "data": {
        "synced": ["003139", "003140"],
        "synced_count": 2,
        "already_used": [],
        "already_used_count": 0,
        "not_found": [],
        "not_found_count": 0,
        "failed": [],
        "failed_count": 0
    }
}
POST
/api/mobile/codes/mark-used
Mark a single code as used.
Request Body
{
    "code": "003150",
    "device_id": "DEVICE-UUID-12345",
    "used_at": "2026-01-06T10:30:00Z"
}
Success Response (200 OK)
{
    "success": true,
    "message": "Code marked as used",
    "data": {
        "code": "003150",
        "used": true,
        "used_at": "2026-01-06T10:30:00.000000Z"
    }
}
GET
/api/mobile/codes/stats
Description: Comprehensive statistics about codes.
Success Response (200 OK)
{
    "success": true,
    "data": {
        "total": 5000,
        "used": 150,
        "available": 4850,
        "usage_percentage": 3,
        "by_device": [
            {"device_id": "DEVICE-001", "used_count": 100},
            {"device_id": "DEVICE-002", "used_count": 50}
        ],
        "batches": {
            "active": 1,
            "exhausted": 0,
            "total": 1
        }
    }
}
GET
/api/mobile/codes/unsynced
Get codes that have been used but not yet synchronized.
Query Parameters
Parameter	Type	Required	Description
limit	integer	No	Maximum results (1-500)
device_id	string	No	Filter by device ID
📱 Mobile Implementation Guide (Dart)
// ===================================================
// 1. On Login (Very Important!)
// ===================================================
Future<void> onLoginSuccess(String token) async {
  // Get locally stored codes with their status
  List<Map> localCodes = await localDb.getAllCodes();

  // Call sync endpoint
  final response = await api.post('/mobile/codes/login-sync', {
    'device_id': deviceId,
    'device_codes': localCodes.map((c) => {
      'code': c['code'],
      'used': c['is_used'] == 1,
      'used_at': c['used_at'],
      'record_id': c['record_id']?.toString(),
    }).toList(),
  });

  if (response['success']) {
    final data = response['data'];

    // Delete invalid codes
    for (var invalid in data['sync_result']['invalid_codes']) {
      await localDb.deleteCode(invalid['code']);
    }

    // Save new codes locally
    await localDb.saveNewCodes(data['new_codes']);

    // Update device stats
    await saveDeviceStats(data['device_stats']);
  }
}

// ===================================================
// 2. Using Code Offline
// ===================================================
Future<String?> useCodeOffline(String recordType, int recordId) async {
  // Get first unused code
  final code = await localDb.getFirstUnusedCode();
  if (code == null) {
    throw Exception('No codes available! Please connect to internet');
  }

  // Mark code as used locally
  await localDb.markCodeAsUsed(
    code: code,
    usedAt: DateTime.now(),
    recordType: recordType,
    recordId: recordId,
    synced: false,
  );

  return code;
}

// ===================================================
// 3. When Coming Online
// ===================================================
Future<void> syncUsedCodes() async {
  // Get unsynced used codes
  final unsyncedCodes = await localDb.getUnsyncedCodes();

  if (unsyncedCodes.isEmpty) return;

  // Send to server
  final response = await api.post('/mobile/codes/confirm-usage', {
    'device_id': deviceId,
    'codes': unsyncedCodes.map((c) => {
      'code': c['code'],
      'used_at': c['used_at'],
      'record_type': c['record_type'],
      'record_id': c['record_id'],
    }).toList(),
  });

  // Update sync status locally
  if (response['success']) {
    for (var code in response['data']['confirmed']) {
      await localDb.markAsSynced(code);
    }
  }
}

// ===================================================
// 4. Periodic Balance Check
// ===================================================
Future<void> checkAndRefillCodes() async {
  if (!await isOnline()) return;

  // Get device stats
  final stats = await api.get('/mobile/codes/device-stats', {
    'device_id': deviceId,
  });

  final unusedCount = stats['data']['unused_count'];
  final canRequestMore = stats['data']['can_request_more'];

  // If balance is low, request more
  if (unusedCount < 100 && canRequestMore) {
    final response = await api.post('/mobile/codes/request-codes', {
      'device_id': deviceId,
      'count': 500,
    });

    if (response['success']) {
      await localDb.saveNewCodes(response['data']['codes']);
    }
  }
}
💾 SQLite Schema for Mobile App
-- Local codes table
CREATE TABLE local_codes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT UNIQUE NOT NULL,
    is_used INTEGER DEFAULT 0,
    used_at TEXT,
    synced INTEGER DEFAULT 0,
    record_type TEXT,
    record_id INTEGER,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Index for unused codes (performance)
CREATE INDEX idx_unused ON local_codes(is_used) WHERE is_used = 0;

-- Index for unsynced codes
CREATE INDEX idx_unsynced ON local_codes(synced, is_used) WHERE synced = 0 AND is_used = 1;
⚠️ Error Codes
Code	Message	Description	Solution
validation_error	Invalid data	Data validation error	Check submitted data
limit_reached	Limit reached	Device has 5000 codes already	Use existing codes first
no_codes_available	No codes available	Codes depleted on server	Ask admin to create new batch
no_active_batch	No active batch	No batch created yet	Admin must create a batch
code_not_found	Code not found	Code not in system	Ignore this code
not_mobile_code	Not mobile code	Code not for mobile use	Delete code locally
