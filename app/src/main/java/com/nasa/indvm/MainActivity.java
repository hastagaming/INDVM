package com.nasa.indvm;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private TextView pathLabel;
    private EditText vmNameInput, paramsInput;
    private Uri selectedIsoUri;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Inisialisasi UI
        pathLabel = findViewById(R.id.path_label);
        vmNameInput = findViewById(R.id.vm_name);
        paramsInput = findViewById(R.id.qemu_params);
        Button btnSelectIso = findViewById(R.id.btn_select_iso);
        Button btnRun = findViewById(R.id.btn_run);

        // Fungsi Pilih File (Vectras Style)
        ActivityResultLauncher<Intent> filePicker = registerForActivityResult(
            new ActivityResultContracts.StartActivityForResult(),
            result -> {
                if (result.getResultCode() == Activity.RESULT_OK && result.getData() != null) {
                    selectedIsoUri = result.getData().getData();
                    pathLabel.setText("File: " + selectedIsoUri.getLastPathSegment());
                }
            }
        );

        btnSelectIso.setOnClickListener(v -> {
            Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
            intent.addCategory(Intent.CATEGORY_OPENABLE);
            intent.setType("*/*");
            filePicker.launch(intent);
        });

        // Jalankan VM dengan Params (Limbo Style)
        btnRun.setOnClickListener(v -> {
            String vmName = vmNameInput.getText().toString();
            String extraParams = paramsInput.getText().toString();

            if (selectedIsoUri == null) {
                Toast.makeText(this, "Pilih ISO terlebih dahulu!", Toast.LENGTH_SHORT).show();
            } else {
                // Logika menjalankan QEMU dengan params
                String pesan = "Booting " + (vmName.isEmpty() ? "INDVM" : vmName) + 
                               "\nParams: " + extraParams;
                Toast.makeText(this, pesan, Toast.LENGTH_LONG).show();
            }
        });
    }
}
