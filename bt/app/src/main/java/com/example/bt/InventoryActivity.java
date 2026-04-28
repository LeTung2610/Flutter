package com.example.bt;

import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import java.util.ArrayList;

public class InventoryActivity extends AppCompatActivity {

    private Button btnAddThuoc, btnBackToHome;
    private ListView lvThuoc;
    private DatabaseHelper dbHelper;

    private ArrayList<String> listThuoc;
    private ArrayList<Integer> listIdThuoc; // Danh sách ngầm chứa ID để biết xóa thuốc nào
    private ArrayAdapter<String> adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_inventory);

        btnAddThuoc = findViewById(R.id.btnAddThuoc);
        lvThuoc = findViewById(R.id.lvThuoc);
        btnBackToHome = findViewById(R.id.btnBackToHome);
        dbHelper = new DatabaseHelper(this);

        listThuoc = new ArrayList<>();
        listIdThuoc = new ArrayList<>();
        adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, listThuoc);
        lvThuoc.setAdapter(adapter);

        btnBackToHome.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        btnAddThuoc.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(InventoryActivity.this, AddMedicineActivity.class);
                startActivity(intent);
            }
        });

        // ========================================================
        // TÍNH NĂNG MỚI: NHẤN GIỮ ĐỂ XÓA THUỐC
        // ========================================================
        lvThuoc.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
            @Override
            public boolean onItemLongClick(AdapterView<?> parent, View view, final int position, long id) {
                // Lấy ID thật của hộp thuốc trong Database
                final int thuocId = listIdThuoc.get(position);

                // Hiện hộp thoại hỏi cho chắc chắn
                AlertDialog.Builder builder = new AlertDialog.Builder(InventoryActivity.this);
                builder.setTitle("Xác nhận xóa");
                builder.setMessage("Bạn có chắc chắn muốn xóa loại thuốc này khỏi kho không?");

                builder.setPositiveButton("XÓA", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dbHelper.deleteThuoc(thuocId); // Xóa trong Database
                        Toast.makeText(InventoryActivity.this, "Đã xóa thuốc!", Toast.LENGTH_SHORT).show();
                        loadThuocData(); // Vẽ lại danh sách mới
                    }
                });

                builder.setNegativeButton("HỦY", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss(); // Đóng hộp thoại, không làm gì cả
                    }
                });

                builder.show();
                return true; // Báo cho hệ thống biết là đã xử lý xong cú nhấn giữ
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        loadThuocData();
    }

    private void loadThuocData() {
        listThuoc.clear();
        listIdThuoc.clear(); // Phải xóa cả danh sách ID cũ đi
        Cursor cursor = dbHelper.getAllThuoc();

        if (cursor.getCount() == 0) {
            listThuoc.add("Kho đang trống. Hãy thêm thuốc mới!");
            listIdThuoc.add(-1); // ID giả cho dòng thông báo
        } else {
            while (cursor.moveToNext()) {
                int id = cursor.getInt(0); // Lấy ID ở cột 0
                String ten = cursor.getString(1);
                int gia = cursor.getInt(2);
                int sl = cursor.getInt(3);

                String thongTin = "💊 " + ten + "\nGiá: " + gia + " VNĐ  |  Tồn kho: " + sl;
                listThuoc.add(thongTin);
                listIdThuoc.add(id); // Cất ID vào túi ngầm
            }
        }

        cursor.close();
        adapter.notifyDataSetChanged();
    }
}