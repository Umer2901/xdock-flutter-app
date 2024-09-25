import 'package:coldxpress/export.dart';
import 'package:path/path.dart';

class DatabaseProvider with ChangeNotifier {
  late Database _database;

  Database get database => _database;

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'coldxpress.db');
    _database = await openDatabase(path, version: 1, onCreate: createTables);
    // Debugging: List all tables to verify creation
    List<Map> list = await _database
        .rawQuery('SELECT name FROM sqlite_master WHERE type="table"');
    notifyListeners();
    return _database;
  }

  Future<void> createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        company_name TEXT,
        email_verified_at TEXT,
        api_token TEXT,
        allowed_login INTEGER,
        required_two_factor INTEGER,
        status INTEGER,
        admin INTEGER,
        two_factor_expires_at TEXT,
        two_factor_code INTEGER,
        created_at TEXT,
        updated_at TEXT,
        warehouse TEXT,
        tnc_flag INTEGER,
        is_driver INTEGER,
        driver_income_percentage TEXT,
        online INTEGER,
        location_access INTEGER,
        last_logged_in TEXT,
        phone_number TEXT,
        is_contractor INTEGER,
        contractor_id TEXT,
        outstanding_pallets INTEGER,
        is_pallet_manager INTEGER,
        is_storeman INTEGER,
        is_contractor_storeman INTEGER,
        storeman_id TEXT,
        allow_sort_consignment INTEGER,
        is_scanning_staff INTEGER,
        access_token TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS precheck_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        checklist INTEGER,
        outbound INTEGER,
        inbound INTEGER,
        datetime TEXT,
        access_token TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS consignments (
        id INTEGER PRIMARY KEY,
        invoice_id INTEGER,
        driver_invoice_id INTEGER,
        removed_from_driver_invoice INTEGER,
        sale_order_id INTEGER,
        customer_reference TEXT,
        barcode TEXT,
        consignment_type TEXT,
        multi_leg INTEGER,
        carton INTEGER,
        pallet INTEGER,
        space INTEGER,
        weight REAL,
        hand_unload_fee_applied INTEGER,
        invoice_value REAL,
        comment TEXT,
        status TEXT,
        date_delivered TEXT,
        manifest_id INTEGER,
        rate_zone_id INTEGER,
        manually_assigned_rate_zone INTEGER,
        cash_on_delivery INTEGER,
        complete_cod INTEGER,
        cod_value REAL,
        cod_requirement TEXT,
        delivery_date TEXT,
        required_delivery_date TEXT,
        special_instruction TEXT,
        save_special_instruction INTEGER,
        confirm TEXT,
        finalize INTEGER,
        end_date TEXT,
        next_date TEXT,
        repeat_every TEXT,
        repeat_count INTEGER,
        is_repeat INTEGER,
        no_charge INTEGER,
        parent_repeat_id INTEGER,
        created_at TEXT,
        is_group TEXT,
        sort_arrival INTEGER,
        delivery_address_string_id INTEGER,
        pickup_address_string_id INTEGER,
        cc_consignment_id INTEGER,
        is_printed INTEGER,
        signature TEXT,
        temperature TEXT,
        recevied_by_name TEXT,
        runsheet_id INTEGER,
        sort INTEGER,
        osrm_sort INTEGER,
        osrm_eta TEXT,
        original_carton INTEGER,
        original_pallet INTEGER,
        original_space INTEGER,
        original_weight REAL,
        validated INTEGER,
        grouping_flag INTEGER,
        pop_temperature TEXT,
        pop_recevied_by_name TEXT,
        pop_signature TEXT,
        date_picked TEXT,
        is_unassigned INTEGER,
        deleted_at TEXT,
        loadsheet_pallet_id INTEGER,
        delivery_addresses TEXT,
        pickup_addresses TEXT,
        delivery_runs TEXT,
        customers TEXT,
        product_types TEXT,
        run_sheets TEXT,
        consignment_pallets TEXT,
        grouped_consignments TEXT,
        total_grouped_consignments INTEGER DEFAULT 0,
        customer_id INTEGER,
        product_type_id INTEGER,
        delivery_run_id INTEGER,
        pickup_address INTEGER,
        delivery_address INTEGER,
        datetime TEXT,
        access_token TEXT,
        address_grouping INTEGER,
        required_delivery_time TEXT,
        is_complete INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_task (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_name TEXT,
        task_type TEXT,
        data TEXT,
        access_token TEXT,
        is_sync TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS full_delivery (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pod_type INTEGER,
        carton INTEGER,
        pallet INTEGER,
        lengthOfDelivery INTEGER,
        device TEXT,
        space INTEGER,
        weight TEXT,
        first_name TEXT,
        last_name TEXT,
        temp TEXT,
        temperature TEXT,
        signature TEXT,
        comments TEXT,
        service_window TEXT,
        service_time_start TEXT,
        service_time_end TEXT,
        address_id INTEGER,  
        customer_reference TEXT,
        pictures TEXT,
        consignments TEXT,
        pictureSources TEXT,
        latitude TEXT,
        longitude TEXT,
        consignment_id INTEGER,
        is_virtual INTEGER,
        manufacturer TEXT,
        model TEXT,
        platform TEXT,
        serial TEXT,
        uuid TEXT,
        version TEXT,
        app_version TEXT,
        driver_id INTEGER,
        date_delivered TEXT,
        platforms TEXT,
        company_name TEXT,
        access_token,
        current_app_version TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS partial_delivery (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        carton INTEGER,
        pallet INTEGER,
        lengthofDelivery INTEGER,
        device TEXT,
        space TEXT,
        weight TEXT,
        first_name TEXT,
        last_name TEXT,
        temperature TEXT,
        temp TEXT,
        signature TEXT,
        comments TEXT,
        service_window TEXT,
        service_time_start TEXT,
        service_time_end TEXT,
        address_id INTEGER,
        pod_type INTEGER,
        customer_reference TEXT,
        pictures TEXT,
        consignments TEXT,
        pictureSources TEXT,
        latitude TEXT,
        longitude TEXT,
        consignment_id INTEGER,
        is_virtual INTEGER,
        manufacturer TEXT,
        model TEXT,
        platform TEXT,
        serial TEXT,
        uuid TEXT,
        version TEXT,
        app_version TEXT,
        driver_id INTEGER,
        date_delivered TEXT,
        current_app_version TEXT,
        reason TEXT,
        lodgeError TEXT,
        company_name TEXT,
        access_token,
        platforms TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS none_delivery (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pod_type INTEGER,
        error_type TEXT,
        temp TEXT,
        rejection_reason TEXT,
        comments TEXT,
        record_error INTEGER,
        adhoc_charges INTEGER, 
        space REAL,
        weight REAL,
        consignments TEXT, 
        device TEXT,
        date_delivered TEXT,
        driver_id INTEGER,
        first_name TEXT,
        last_name TEXT,
        customer_probe_temp TEXT,
        driver_probe_temp TEXT,
        driver_infrared_temp TEXT,
        where_temp_checked TEXT,
        customer_probe_checked INTEGER,
        customer_probe_why TEXT,
        pictures TEXT,
        pictureSources TEXT,
        app_version TEXT,
        current_app_version TEXT,
        platforms TEXT,
        company_name TEXT,
        access_token,
        consignment_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS group_delivery (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pod_type INTEGER,
        carton INTEGER,
        pallet INTEGER,
        lengthOfDelivery INTEGER,
        device TEXT,
        space INTEGER,
        weight TEXT,
        first_name TEXT,
        last_name TEXT,
        temperature TEXT,
        signature TEXT,
        comments TEXT,
        service_window TEXT,
        service_time_start TEXT,
        service_time_end TEXT,
        address_id INTEGER,  
        customer_reference TEXT,
        pictures TEXT,
        consignments TEXT,
        pictureSources TEXT,
        latitude TEXT,
        longitude TEXT,
        consignment_id INTEGER,
        driver_id INTEGER,
        date_delivered TEXT,
        platforms TEXT,
        access_token,
        current_app_version TEXT
      )
    ''');
  }

  Future<void> deleteDatabase() async {
    final path = join(await getDatabasesPath(), 'coldxpress.db');
    await databaseFactory.deleteDatabase(path);
  }
}
