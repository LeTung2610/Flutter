package com.example.bt;

import android.database.Cursor;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import java.util.ArrayList;

public class RevenueActivity extends AppCompatActivity {

    private Button btnBack;
    private TextView tvTongDoanhThu;
    private ListView lvLichSuHoaDon;
    private DatabaseHelper dbHelper;

    private ArrayList<String> listHoaDon;
    private ArrayAdapter<String> adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_revenue);

        btnBack = findViewById(R.id.btnBackToHomeFromRev);
        tvTongDoanhThu = findViewById(R.id.tvTongDoanhThu);
        lvLichSuHoaDon = findViewById(R.id.lvLichSuHoaDon);
        dbHelper = new DatabaseHelper(this);

        listHoaDon = new ArrayList<>();
        adapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, listHoaDon);
        lvLichSuHoaDon.setAdapter(adapter);

        btnBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

        loadDoanhThuData();
    }

    private void loadDoanhThuData() {
        listHoaDon.clear();
        Cursor cursor = dbHelper.getAllHoaDon();

        long tongDoanhThu = 0; // Biến cộng dồn tiền

        if (cursor.getCount() == 0) {
            listHoaDon.add("Chưa có hóa đơn nào được bán ra.");
        } else {
            while (cursor.moveToNext()) {
                String ngayTao = cursor.getString(1);
                String chiTiet = cursor.getString(2);
                int tongTien = cursor.getInt(3);

                // Cộng tiền vào tổng doanh thu
                tongDoanhThu += tongTien;

                // Trang trí đoạn văn bản để hiện lên danh sách
                String thongTin = "🕒 " + ngayTao + "\n" +
                        "Chi tiết:\n" + chiTiet +
                        "💰 Thu về: " + tongTien + " VNĐ";
                listHoaDon.add(thongTin);
            }
        }
        cursor.close();
        adapter.notifyDataSetChanged();

        // Ghi tổng tiền lên cái bảng màu xanh lá cây
        tvTongDoanhThu.setText(tongDoanhThu + " VNĐ");
    }
}