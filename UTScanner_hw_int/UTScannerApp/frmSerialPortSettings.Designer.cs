
namespace UTScannerApp
{
    partial class frmSerialPortSettings
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.grbTP = new System.Windows.Forms.GroupBox();
            this.label2 = new System.Windows.Forms.Label();
            this.numDataBit = new System.Windows.Forms.NumericUpDown();
            this.cmbPortname = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.lblSerialPort = new System.Windows.Forms.Label();
            this.numBautRate = new System.Windows.Forms.NumericUpDown();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label3 = new System.Windows.Forms.Label();
            this.numMCDB = new System.Windows.Forms.NumericUpDown();
            this.cmbMCPort = new System.Windows.Forms.ComboBox();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.numBR = new System.Windows.Forms.NumericUpDown();
            this.grbTP.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numDataBit)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numBautRate)).BeginInit();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numMCDB)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numBR)).BeginInit();
            this.SuspendLayout();
            // 
            // grbTP
            // 
            this.grbTP.Controls.Add(this.label2);
            this.grbTP.Controls.Add(this.numDataBit);
            this.grbTP.Controls.Add(this.cmbPortname);
            this.grbTP.Controls.Add(this.label1);
            this.grbTP.Controls.Add(this.lblSerialPort);
            this.grbTP.Controls.Add(this.numBautRate);
            this.grbTP.Dock = System.Windows.Forms.DockStyle.Top;
            this.grbTP.Location = new System.Drawing.Point(0, 0);
            this.grbTP.Name = "grbTP";
            this.grbTP.Size = new System.Drawing.Size(410, 209);
            this.grbTP.TabIndex = 0;
            this.grbTP.TabStop = false;
            this.grbTP.Text = "Touch Panel Settings";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(75, 136);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(54, 17);
            this.label2.TabIndex = 19;
            this.label2.Text = "DataBit";
            // 
            // numDataBit
            // 
            this.numDataBit.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.numDataBit.Location = new System.Drawing.Point(249, 130);
            this.numDataBit.Name = "numDataBit";
            this.numDataBit.Size = new System.Drawing.Size(75, 23);
            this.numDataBit.TabIndex = 18;
            this.numDataBit.Value = new decimal(new int[] {
            8,
            0,
            0,
            0});
            // 
            // cmbPortname
            // 
            this.cmbPortname.FormattingEnabled = true;
            this.cmbPortname.Location = new System.Drawing.Point(207, 51);
            this.cmbPortname.Name = "cmbPortname";
            this.cmbPortname.Size = new System.Drawing.Size(121, 25);
            this.cmbPortname.TabIndex = 17;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(75, 51);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(75, 17);
            this.label1.TabIndex = 16;
            this.label1.Text = "Port Name";
            // 
            // lblSerialPort
            // 
            this.lblSerialPort.AutoSize = true;
            this.lblSerialPort.Location = new System.Drawing.Point(75, 99);
            this.lblSerialPort.Name = "lblSerialPort";
            this.lblSerialPort.Size = new System.Drawing.Size(67, 17);
            this.lblSerialPort.TabIndex = 15;
            this.lblSerialPort.Text = "BautRate";
            // 
            // numBautRate
            // 
            this.numBautRate.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.numBautRate.Location = new System.Drawing.Point(249, 93);
            this.numBautRate.Maximum = new decimal(new int[] {
            100000,
            0,
            0,
            0});
            this.numBautRate.Name = "numBautRate";
            this.numBautRate.Size = new System.Drawing.Size(75, 23);
            this.numBautRate.TabIndex = 14;
            this.numBautRate.Value = new decimal(new int[] {
            9600,
            0,
            0,
            0});
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.numMCDB);
            this.groupBox1.Controls.Add(this.cmbMCPort);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.numBR);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBox1.Location = new System.Drawing.Point(0, 209);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(410, 209);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "MC Settings";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(75, 136);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(54, 17);
            this.label3.TabIndex = 19;
            this.label3.Text = "DataBit";
            // 
            // numMCDB
            // 
            this.numMCDB.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.numMCDB.Location = new System.Drawing.Point(249, 130);
            this.numMCDB.Name = "numMCDB";
            this.numMCDB.Size = new System.Drawing.Size(75, 23);
            this.numMCDB.TabIndex = 18;
            this.numMCDB.Value = new decimal(new int[] {
            8,
            0,
            0,
            0});
            //
            // cmbMCPort
            // 
            this.cmbMCPort.FormattingEnabled = true;
            this.cmbMCPort.Location = new System.Drawing.Point(207, 51);
            this.cmbMCPort.Name = "cmbMCPort";
            this.cmbMCPort.Size = new System.Drawing.Size(121, 25);
            this.cmbMCPort.TabIndex = 17;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(75, 51);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(75, 17);
            this.label4.TabIndex = 16;
            this.label4.Text = "Port Name";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(75, 99);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(67, 17);
            this.label5.TabIndex = 15;
            this.label5.Text = "BautRate";
            // 
            // numBR
            // 
            this.numBR.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)));
            this.numBR.Location = new System.Drawing.Point(249, 93);
            this.numBR.Maximum = new decimal(new int[] {
            100000,
            0,
            0,
            0});
            this.numBR.Name = "numBR";
            this.numBR.Size = new System.Drawing.Size(75, 23);
            this.numBR.TabIndex = 14;
            this.numBR.Value = new decimal(new int[] {
            9600,
            0,
            0,
            0});
            // 
            // frmSerialPortSettings
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 17F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(410, 420);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.grbTP);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmSerialPortSettings";
            this.ShowIcon = false;
            this.Text = "SerialPortConfig";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.frmSerialPortSettings_FormClosing);
            this.grbTP.ResumeLayout(false);
            this.grbTP.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numDataBit)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numBautRate)).EndInit();
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numMCDB)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numBR)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox grbTP;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.NumericUpDown numDataBit;
        private System.Windows.Forms.ComboBox cmbPortname;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label lblSerialPort;
        private System.Windows.Forms.NumericUpDown numBautRate;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.NumericUpDown numMCDB;
        private System.Windows.Forms.ComboBox cmbMCPort;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.NumericUpDown numBR;
    }
}