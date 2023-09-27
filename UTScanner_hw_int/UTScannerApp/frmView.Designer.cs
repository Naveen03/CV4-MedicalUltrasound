
namespace UTScannerApp
{
    partial class frmView
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
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmView));
            this.tip = new System.Windows.Forms.ToolTip(this.components);
            this.SplitParant = new System.Windows.Forms.SplitContainer();
            this.tblyt = new System.Windows.Forms.TableLayoutPanel();
            this.lblPatientName = new System.Windows.Forms.Label();
            this.lblPatientID = new System.Windows.Forms.Label();
            this.pbx = new System.Windows.Forms.PictureBox();
            this.btnDirection = new System.Windows.Forms.Button();
            this.lblHospitalName = new System.Windows.Forms.Label();
            this.pnlDir = new System.Windows.Forms.Panel();
            this.lblSampleFreq = new System.Windows.Forms.Label();
            this.splitV = new System.Windows.Forms.SplitContainer();
            this.splitBase = new System.Windows.Forms.SplitContainer();
            this.splitTop = new System.Windows.Forms.SplitContainer();
            this.splitBottom = new System.Windows.Forms.SplitContainer();
            this.btnStartmeasurement = new System.Windows.Forms.Button();
            this.btnCapture = new System.Windows.Forms.Button();
            this.lblStatus = new System.Windows.Forms.Label();
            this.btnMeasurement = new System.Windows.Forms.Button();
            this.btnUndo = new System.Windows.Forms.Button();
            this.cmbScanModeSelecion = new System.Windows.Forms.ComboBox();
            this.cmbViewLayout = new System.Windows.Forms.ComboBox();
            this.trkBar = new System.Windows.Forms.TrackBar();
            this.btnReset = new System.Windows.Forms.Button();
            this.btnSave = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.SplitParant)).BeginInit();
            this.SplitParant.Panel1.SuspendLayout();
            this.SplitParant.Panel2.SuspendLayout();
            this.SplitParant.SuspendLayout();
            this.tblyt.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pbx)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.splitV)).BeginInit();
            this.splitV.Panel1.SuspendLayout();
            this.splitV.Panel2.SuspendLayout();
            this.splitV.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitBase)).BeginInit();
            this.splitBase.Panel1.SuspendLayout();
            this.splitBase.Panel2.SuspendLayout();
            this.splitBase.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitTop)).BeginInit();
            this.splitTop.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitBottom)).BeginInit();
            this.splitBottom.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trkBar)).BeginInit();
            this.SuspendLayout();
            // 
            // SplitParant
            // 
            this.SplitParant.Dock = System.Windows.Forms.DockStyle.Fill;
            this.SplitParant.Location = new System.Drawing.Point(0, 0);
            this.SplitParant.Name = "SplitParant";
            this.SplitParant.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // SplitParant.Panel1
            // 
            this.SplitParant.Panel1.Controls.Add(this.tblyt);
            // 
            // SplitParant.Panel2
            // 
            this.SplitParant.Panel2.Controls.Add(this.splitV);
            this.SplitParant.Size = new System.Drawing.Size(1269, 763);
            this.SplitParant.SplitterDistance = 73;
            this.SplitParant.TabIndex = 0;
            // 
            // tblyt
            // 
            this.tblyt.ColumnCount = 5;
            this.tblyt.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 70F));
            this.tblyt.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 300F));
            this.tblyt.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 300F));
            this.tblyt.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 300F));
            this.tblyt.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 299F));
            this.tblyt.Controls.Add(this.lblPatientName, 2, 0);
            this.tblyt.Controls.Add(this.lblPatientID, 1, 0);
            this.tblyt.Controls.Add(this.pbx, 0, 0);
            this.tblyt.Controls.Add(this.btnDirection, 0, 1);
            this.tblyt.Controls.Add(this.lblHospitalName, 3, 0);
            this.tblyt.Controls.Add(this.pnlDir, 1, 1);
            this.tblyt.Controls.Add(this.lblSampleFreq, 4, 0);
            this.tblyt.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tblyt.Location = new System.Drawing.Point(0, 0);
            this.tblyt.Name = "tblyt";
            this.tblyt.RowCount = 2;
            this.tblyt.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 50F));
            this.tblyt.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 50F));
            this.tblyt.Size = new System.Drawing.Size(1269, 73);
            this.tblyt.TabIndex = 1;
            // 
            // lblPatientName
            // 
            this.lblPatientName.AutoSize = true;
            this.lblPatientName.BackColor = System.Drawing.Color.Transparent;
            this.lblPatientName.Font = new System.Drawing.Font("Microsoft Sans Serif", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPatientName.ForeColor = System.Drawing.Color.White;
            this.lblPatientName.Location = new System.Drawing.Point(380, 10);
            this.lblPatientName.Margin = new System.Windows.Forms.Padding(10);
            this.lblPatientName.Name = "lblPatientName";
            this.lblPatientName.Size = new System.Drawing.Size(184, 20);
            this.lblPatientName.TabIndex = 5;
            this.lblPatientName.Text = "Patient Name : TEST-A";
            // 
            // lblPatientID
            // 
            this.lblPatientID.AutoSize = true;
            this.lblPatientID.BackColor = System.Drawing.Color.Transparent;
            this.lblPatientID.Font = new System.Drawing.Font("Microsoft Sans Serif", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPatientID.ForeColor = System.Drawing.Color.White;
            this.lblPatientID.Location = new System.Drawing.Point(80, 10);
            this.lblPatientID.Margin = new System.Windows.Forms.Padding(10);
            this.lblPatientID.Name = "lblPatientID";
            this.lblPatientID.Size = new System.Drawing.Size(145, 20);
            this.lblPatientID.TabIndex = 8;
            this.lblPatientID.Text = "Patient ID : TEST ";
            // 
            // pbx
            // 
            this.pbx.Dock = System.Windows.Forms.DockStyle.Left;
            this.pbx.Image = ((System.Drawing.Image)(resources.GetObject("pbx.Image")));
            this.pbx.Location = new System.Drawing.Point(3, 3);
            this.pbx.Name = "pbx";
            this.pbx.Size = new System.Drawing.Size(64, 44);
            this.pbx.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pbx.TabIndex = 13;
            this.pbx.TabStop = false;
            // 
            // btnDirection
            // 
            this.btnDirection.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.btnDirection.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnDirection.BackgroundImage")));
            this.btnDirection.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnDirection.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnDirection.Location = new System.Drawing.Point(7, 53);
            this.btnDirection.Name = "btnDirection";
            this.btnDirection.Size = new System.Drawing.Size(55, 19);
            this.btnDirection.TabIndex = 12;
            this.btnDirection.UseVisualStyleBackColor = true;
            this.btnDirection.Click += new System.EventHandler(this.btnDirection_Click);
            // 
            // lblHospitalName
            // 
            this.lblHospitalName.AutoSize = true;
            this.lblHospitalName.BackColor = System.Drawing.Color.Transparent;
            this.lblHospitalName.Font = new System.Drawing.Font("Microsoft Sans Serif", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblHospitalName.ForeColor = System.Drawing.Color.White;
            this.lblHospitalName.Location = new System.Drawing.Point(680, 10);
            this.lblHospitalName.Margin = new System.Windows.Forms.Padding(10);
            this.lblHospitalName.Name = "lblHospitalName";
            this.lblHospitalName.Size = new System.Drawing.Size(46, 20);
            this.lblHospitalName.TabIndex = 12;
            this.lblHospitalName.Text = "TI/MI";
            // 
            // pnlDir
            // 
            this.pnlDir.Location = new System.Drawing.Point(73, 53);
            this.pnlDir.Name = "pnlDir";
            this.pnlDir.Size = new System.Drawing.Size(159, 19);
            this.pnlDir.TabIndex = 11;
            // 
            // lblSampleFreq
            // 
            this.lblSampleFreq.AutoSize = true;
            this.lblSampleFreq.BackColor = System.Drawing.Color.Transparent;
            this.lblSampleFreq.Font = new System.Drawing.Font("Microsoft Sans Serif", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblSampleFreq.ForeColor = System.Drawing.Color.White;
            this.lblSampleFreq.Location = new System.Drawing.Point(980, 10);
            this.lblSampleFreq.Margin = new System.Windows.Forms.Padding(10);
            this.lblSampleFreq.Name = "lblSampleFreq";
            this.lblSampleFreq.Size = new System.Drawing.Size(109, 20);
            this.lblSampleFreq.TabIndex = 6;
            this.lblSampleFreq.Text = "SampleFreq :";
            // 
            // splitV
            // 
            this.splitV.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitV.Location = new System.Drawing.Point(0, 0);
            this.splitV.Name = "splitV";
            this.splitV.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitV.Panel1
            // 
            this.splitV.Panel1.Controls.Add(this.splitBase);
            // 
            // splitV.Panel2
            // 
            this.splitV.Panel2.Controls.Add(this.btnStartmeasurement);
            this.splitV.Panel2.Controls.Add(this.btnCapture);
            this.splitV.Panel2.Controls.Add(this.lblStatus);
            this.splitV.Panel2.Controls.Add(this.btnMeasurement);
            this.splitV.Panel2.Controls.Add(this.btnUndo);
            this.splitV.Panel2.Controls.Add(this.cmbScanModeSelecion);
            this.splitV.Panel2.Controls.Add(this.cmbViewLayout);
            this.splitV.Panel2.Controls.Add(this.trkBar);
            this.splitV.Panel2.Controls.Add(this.btnReset);
            this.splitV.Panel2.Controls.Add(this.btnSave);
            this.splitV.Size = new System.Drawing.Size(1269, 686);
            this.splitV.SplitterDistance = 650;
            this.splitV.TabIndex = 14;
            // 
            // splitBase
            // 
            this.splitBase.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitBase.Location = new System.Drawing.Point(0, 0);
            this.splitBase.Name = "splitBase";
            this.splitBase.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitBase.Panel1
            // 
            this.splitBase.Panel1.Controls.Add(this.splitTop);
            // 
            // splitBase.Panel2
            // 
            this.splitBase.Panel2.Controls.Add(this.splitBottom);
            this.splitBase.Size = new System.Drawing.Size(1269, 650);
            this.splitBase.SplitterDistance = 311;
            this.splitBase.TabIndex = 2;
            // 
            // splitTop
            // 
            this.splitTop.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitTop.Location = new System.Drawing.Point(0, 0);
            this.splitTop.Name = "splitTop";
            this.splitTop.Size = new System.Drawing.Size(1269, 311);
            this.splitTop.SplitterDistance = 630;
            this.splitTop.TabIndex = 0;
            // 
            // splitBottom
            // 
            this.splitBottom.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitBottom.Location = new System.Drawing.Point(0, 0);
            this.splitBottom.Name = "splitBottom";
            this.splitBottom.Size = new System.Drawing.Size(1269, 335);
            this.splitBottom.SplitterDistance = 628;
            this.splitBottom.TabIndex = 0;
            // 
            // btnStartmeasurement
            // 
            this.btnStartmeasurement.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnStartmeasurement.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnStartmeasurement.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnStartmeasurement.ForeColor = System.Drawing.Color.Black;
            this.btnStartmeasurement.Location = new System.Drawing.Point(415, 0);
            this.btnStartmeasurement.Name = "btnStartmeasurement";
            this.btnStartmeasurement.Size = new System.Drawing.Size(225, 32);
            this.btnStartmeasurement.TabIndex = 22;
            this.btnStartmeasurement.Tag = "Measurment";
            this.btnStartmeasurement.Text = "Show/Hide Linear Mesurement";
            this.btnStartmeasurement.UseVisualStyleBackColor = true;
            this.btnStartmeasurement.Click += new System.EventHandler(this.btnStartmeasurement_Click);
            // 
            // btnCapture
            // 
            this.btnCapture.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnCapture.BackgroundImage")));
            this.btnCapture.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnCapture.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnCapture.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnCapture.ForeColor = System.Drawing.Color.Black;
            this.btnCapture.Location = new System.Drawing.Point(379, 0);
            this.btnCapture.Name = "btnCapture";
            this.btnCapture.Size = new System.Drawing.Size(36, 32);
            this.btnCapture.TabIndex = 21;
            this.btnCapture.UseVisualStyleBackColor = true;
            this.btnCapture.Click += new System.EventHandler(this.btnCapture_Click);
            // 
            // lblStatus
            // 
            this.lblStatus.AutoSize = true;
            this.lblStatus.Dock = System.Windows.Forms.DockStyle.Right;
            this.lblStatus.ForeColor = System.Drawing.Color.White;
            this.lblStatus.Location = new System.Drawing.Point(1221, 0);
            this.lblStatus.Name = "lblStatus";
            this.lblStatus.Size = new System.Drawing.Size(48, 17);
            this.lblStatus.TabIndex = 20;
            this.lblStatus.Text = "Status";
            // 
            // btnMeasurement
            // 
            this.btnMeasurement.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnMeasurement.BackgroundImage")));
            this.btnMeasurement.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnMeasurement.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnMeasurement.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnMeasurement.ForeColor = System.Drawing.Color.Black;
            this.btnMeasurement.Location = new System.Drawing.Point(284, 0);
            this.btnMeasurement.Name = "btnMeasurement";
            this.btnMeasurement.Size = new System.Drawing.Size(95, 32);
            this.btnMeasurement.TabIndex = 19;
            this.btnMeasurement.Tag = "Measurment";
            this.btnMeasurement.UseVisualStyleBackColor = true;
            this.btnMeasurement.Click += new System.EventHandler(this.btnMeasurement_Click);
            // 
            // btnUndo
            // 
            this.btnUndo.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnUndo.BackgroundImage")));
            this.btnUndo.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnUndo.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnUndo.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnUndo.ForeColor = System.Drawing.Color.Black;
            this.btnUndo.Location = new System.Drawing.Point(247, 0);
            this.btnUndo.Name = "btnUndo";
            this.btnUndo.Size = new System.Drawing.Size(37, 32);
            this.btnUndo.TabIndex = 18;
            this.btnUndo.UseVisualStyleBackColor = true;
            this.btnUndo.Click += new System.EventHandler(this.btnUndo_Click);
            // 
            // cmbScanModeSelecion
            // 
            this.cmbScanModeSelecion.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.cmbScanModeSelecion.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbScanModeSelecion.FormattingEnabled = true;
            this.cmbScanModeSelecion.Items.AddRange(new object[] {
            "B",
            "B-A",
            "A",
            "B-M-A",
            "B-M",
            "M"});
            this.cmbScanModeSelecion.Location = new System.Drawing.Point(814, 5);
            this.cmbScanModeSelecion.Name = "cmbScanModeSelecion";
            this.cmbScanModeSelecion.Size = new System.Drawing.Size(144, 24);
            this.cmbScanModeSelecion.TabIndex = 17;
            this.cmbScanModeSelecion.SelectedIndexChanged += new System.EventHandler(this.cmbScanModeSelecion_SelectedIndexChanged);
            // 
            // cmbViewLayout
            // 
            this.cmbViewLayout.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.cmbViewLayout.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbViewLayout.FormattingEnabled = true;
            this.cmbViewLayout.Items.AddRange(new object[] {
            "Single",
            "2-View",
            "4-View"});
            this.cmbViewLayout.Location = new System.Drawing.Point(1011, 3);
            this.cmbViewLayout.Name = "cmbViewLayout";
            this.cmbViewLayout.Size = new System.Drawing.Size(121, 24);
            this.cmbViewLayout.TabIndex = 16;
            this.cmbViewLayout.SelectedIndexChanged += new System.EventHandler(this.cmbViewLayout_SelectedIndexChanged);
            // 
            // trkBar
            // 
            this.trkBar.Dock = System.Windows.Forms.DockStyle.Left;
            this.trkBar.Location = new System.Drawing.Point(71, 0);
            this.trkBar.Name = "trkBar";
            this.trkBar.Size = new System.Drawing.Size(176, 32);
            this.trkBar.TabIndex = 15;
            this.trkBar.Scroll += new System.EventHandler(this.trkBar_Scroll);
            // 
            // btnReset
            // 
            this.btnReset.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnReset.BackgroundImage")));
            this.btnReset.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnReset.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnReset.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnReset.ForeColor = System.Drawing.Color.Black;
            this.btnReset.Location = new System.Drawing.Point(36, 0);
            this.btnReset.Name = "btnReset";
            this.btnReset.Size = new System.Drawing.Size(35, 32);
            this.btnReset.TabIndex = 14;
            this.btnReset.UseVisualStyleBackColor = true;
            this.btnReset.Click += new System.EventHandler(this.btnReset_Click);
            // 
            // btnSave
            // 
            this.btnSave.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnSave.BackgroundImage")));
            this.btnSave.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnSave.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnSave.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnSave.ForeColor = System.Drawing.Color.Black;
            this.btnSave.Location = new System.Drawing.Point(0, 0);
            this.btnSave.Name = "btnSave";
            this.btnSave.Size = new System.Drawing.Size(36, 32);
            this.btnSave.TabIndex = 13;
            this.btnSave.UseVisualStyleBackColor = true;
            this.btnSave.Click += new System.EventHandler(this.btnSave_Click);
            // 
            // frmView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.ClientSize = new System.Drawing.Size(1269, 763);
            this.Controls.Add(this.SplitParant);
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Name = "frmView";
            this.Text = "View";
            this.SplitParant.Panel1.ResumeLayout(false);
            this.SplitParant.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.SplitParant)).EndInit();
            this.SplitParant.ResumeLayout(false);
            this.tblyt.ResumeLayout(false);
            this.tblyt.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pbx)).EndInit();
            this.splitV.Panel1.ResumeLayout(false);
            this.splitV.Panel2.ResumeLayout(false);
            this.splitV.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitV)).EndInit();
            this.splitV.ResumeLayout(false);
            this.splitBase.Panel1.ResumeLayout(false);
            this.splitBase.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitBase)).EndInit();
            this.splitBase.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitTop)).EndInit();
            this.splitTop.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitBottom)).EndInit();
            this.splitBottom.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.trkBar)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.ToolTip tip;
        private System.Windows.Forms.SplitContainer SplitParant;
        private System.Windows.Forms.SplitContainer splitV;
        private System.Windows.Forms.SplitContainer splitBase;
        private System.Windows.Forms.SplitContainer splitTop;
        private System.Windows.Forms.SplitContainer splitBottom;
        private System.Windows.Forms.Button btnStartmeasurement;
        private System.Windows.Forms.Button btnCapture;
        private System.Windows.Forms.Label lblStatus;
        private System.Windows.Forms.Button btnMeasurement;
        private System.Windows.Forms.Button btnUndo;
        private System.Windows.Forms.ComboBox cmbScanModeSelecion;
        private System.Windows.Forms.ComboBox cmbViewLayout;
        private System.Windows.Forms.TrackBar trkBar;
        private System.Windows.Forms.Button btnReset;
        private System.Windows.Forms.Button btnSave;
        private System.Windows.Forms.TableLayoutPanel tblyt;
        private System.Windows.Forms.Label lblPatientName;
        private System.Windows.Forms.Label lblPatientID;
        private System.Windows.Forms.PictureBox pbx;
        private System.Windows.Forms.Button btnDirection;
        private System.Windows.Forms.Label lblHospitalName;
        private System.Windows.Forms.Panel pnlDir;
        private System.Windows.Forms.Label lblSampleFreq;
    }
}