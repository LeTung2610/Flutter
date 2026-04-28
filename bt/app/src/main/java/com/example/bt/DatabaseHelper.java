package com.example.bt;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class DatabaseHelper extends SQLiteOpenHelper {

    private static final String DATABASE_NAME = "PharmacyDB.db";
    private static final int DATABASE_VERSION = 2;

    public DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        String createTableUsers = "CREATE TABLE NguoiDung (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "username TEXT UNIQUE, " +
                "password TEXT, " +
                "role TEXT)";
        db.execSQL(createTableUsers);

        String createTableMedicines = "CREATE TABLE Thuoc (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "tenThuoc TEXT, " +
                "giaBan INTEGER, " +
                "soLuongTon INTEGER, " +
                "hinhAnh TEXT)";
        db.execSQL(createTableMedicines);

        String createTableInvoices = "CREATE TABLE HoaDon (" +
                "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                "ngayTao TEXT, " +
                "chiTiet TEXT, " +
                "tongTien INTEGER)";
        db.execSQL(createTableInvoices);

        db.execSQL("INSERT INTO NguoiDung (username, password, role) VALUES ('admin', '123456', 'QuanLy')");
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS NguoiDung");
        db.execSQL("DROP TABLE IF EXISTS Thuoc");
        db.execSQL("DROP TABLE IF EXISTS HoaDon");
        onCreate(db);
    }

    public boolean checkLogin(String username, String password) {
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery("SELECT * FROM NguoiDung WHERE username = ? AND password = ?", new String[]{username, password});
        boolean isValid = cursor.getCount() > 0;
        cursor.close();
        return isValid;
    }

    public boolean addUser(String username, String password) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put("username", username);
        values.put("password", password);
        values.put("role", "NhanVien");
        long result = db.insert("NguoiDung", null, values);
        return result != -1;
    }

    public boolean addThuoc(String tenThuoc, int giaBan, int soLuongTon) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put("tenThuoc", tenThuoc);
        values.put("giaBan", giaBan);
        values.put("soLuongTon", soLuongTon);
        long result = db.insert("Thuoc", null, values);
        return result != -1;
    }

    public Cursor getAllThuoc() {
        SQLiteDatabase db = this.getReadableDatabase();
        return db.rawQuery("SELECT * FROM Thuoc", null);
    }

    public void deleteThuoc(int id) {
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete("Thuoc", "id=?", new String[]{String.valueOf(id)});
    }

    public boolean addHoaDon(String ngayTao, String chiTiet, int tongTien) {
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put("ngayTao", ngayTao);
        values.put("chiTiet", chiTiet);
        values.put("tongTien", tongTien);
        long result = db.insert("HoaDon", null, values);
        return result != -1;
    }

    public void updateTonKho(int idThuoc, int soLuongBan) {
        SQLiteDatabase db = this.getWritableDatabase();
        db.execSQL("UPDATE Thuoc SET soLuongTon = soLuongTon - " + soLuongBan + " WHERE id = " + idThuoc);
    }
    public Cursor getAllHoaDon() {
        SQLiteDatabase db = this.getReadableDatabase();
        return db.rawQuery("SELECT * FROM HoaDon ORDER BY id DESC", null);
    }
}