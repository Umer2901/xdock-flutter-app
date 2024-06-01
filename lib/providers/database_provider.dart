import 'package:coldxpress/export.dart';
import 'package:path/path.dart';

class DatabaseProvider with ChangeNotifier {
  late Database _database;

  Database get database => _database;

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'coldxpress.db');
    _database = await openDatabase(path, version: 1, onCreate: createTables);
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
        "is_scanning_staff" INTEGER,
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
          CREATE TABLE IF NOT EXISTS consignments(
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
            confirm INTEGER,
            finalize INTEGER,
            end_date TEXT,
            next_date TEXT,
            repeat_every TEXT,
            repeat_count INTEGER,
            is_repeat INTEGER,
            no_charge INTEGER,
            parent_repeat_id INTEGER,
            created_at TEXT,
            is_group INTEGER,
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
            datetime TEXT,
            access_token TEXT,
            is_complete INTEGER DEFAULT 0
          )
        ''');
    await db.execute('''
          CREATE TABLE IF NOT EXISTS sync_task(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_name TEXT,
            task_type TEXT,
            data TEXT
          )
        ''');
    // Create other tables here...
  }

  Future<void> deleteDatabase() async {
    final path = join(await getDatabasesPath(), 'coldxpress.db');
    databaseFactory.deleteDatabase(path);
  }
}
