
namespace UTScannerApp
{
    partial class ucViewer
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

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(ucViewer));
            this.showMeasurementCursorToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.tmrM_Mode = new System.Windows.Forms.Timer(this.components);
            this.tlTip = new System.Windows.Forms.ToolTip(this.components);
            this.cmbScanModeSelecion = new System.Windows.Forms.ComboBox();
            this.cmbViewLayout = new System.Windows.Forms.ComboBox();
            this.btnReset = new System.Windows.Forms.Button();
            this.btnDirection = new System.Windows.Forms.Button();
            this.sfd = new System.Windows.Forms.SaveFileDialog();
            this.ctxtMnu = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.splitMMode = new System.Windows.Forms.SplitContainer();
            this.lblFrameIdx = new System.Windows.Forms.Label();
            this.trkBar = new System.Windows.Forms.TrackBar();
            this.btnPlayPause = new System.Windows.Forms.Button();
            this.btnSave = new System.Windows.Forms.Button();
            this.spltGraphPanel = new System.Windows.Forms.SplitContainer();
            this.tblyt = new System.Windows.Forms.TableLayoutPanel();
            this.lblPatientName = new System.Windows.Forms.Label();
            this.lblPatientID = new System.Windows.Forms.Label();
            this.pbx = new System.Windows.Forms.PictureBox();
            this.lblHospitalName = new System.Windows.Forms.Label();
            this.pnlDir = new System.Windows.Forms.Panel();
            this.lblSampleFreq = new System.Windows.Forms.Label();
            this.splitAMode = new System.Windows.Forms.SplitContainer();
            this.spltViewer = new System.Windows.Forms.SplitContainer();
            this.tmr = new System.Windows.Forms.Timer(this.components);
            this.ctxtMnu.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitMMode)).BeginInit();
            this.splitMMode.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.trkBar)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.spltGraphPanel)).BeginInit();
            this.spltGraphPanel.Panel1.SuspendLayout();
            this.spltGraphPanel.Panel2.SuspendLayout();
            this.spltGraphPanel.SuspendLayout();
            this.tblyt.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pbx)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.splitAMode)).BeginInit();
            this.splitAMode.Panel1.SuspendLayout();
            this.splitAMode.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.spltViewer)).BeginInit();
            this.spltViewer.Panel1.SuspendLayout();
            this.spltViewer.Panel2.SuspendLayout();
            this.spltViewer.SuspendLayout();
            this.SuspendLayout();
            // 
            // showMeasurementCursorToolStripMenuItem
            // 
            this.showMeasurementCursorToolStripMenuItem.Name = "showMeasurementCursorToolStripMenuItem";
            this.showMeasurementCursorToolStripMenuItem.Size = new System.Drawing.Size(254, 24);
            this.showMeasurementCursorToolStripMenuItem.Text = "Show Measurement Cursor";
            // 
            // tmrM_Mode
            // 
            this.tmrM_Mode.Tick += new System.EventHandler(this.tmrM_Mode_Tick);
            // 
            // cmbScanModeSelecion
            // 
            this.cmbScanModeSelecion.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.cmbScanModeSelecion.FormattingEnabled = true;
            this.cmbScanModeSelecion.Items.AddRange(new object[] {
            "B",
            "B-A",
            "A",
            "B-M-A",
            "B-M",
            "M"});
            this.cmbScanModeSelecion.Location = new System.Drawing.Point(480, 25);
            this.cmbScanModeSelecion.Name = "cmbScanModeSelecion";
            this.cmbScanModeSelecion.Size = new System.Drawing.Size(144, 24);
            this.cmbScanModeSelecion.TabIndex = 12;
            this.tlTip.SetToolTip(this.cmbScanModeSelecion, "Mode Selection");
            // 
            // cmbViewLayout
            // 
            this.cmbViewLayout.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.cmbViewLayout.FormattingEnabled = true;
            this.cmbViewLayout.Items.AddRange(new object[] {
            "Single",
            "2-View",
            "3-View",
            "4-View"});
            this.cmbViewLayout.Location = new System.Drawing.Point(189, 29);
            this.cmbViewLayout.Name = "cmbViewLayout";
            this.cmbViewLayout.Size = new System.Drawing.Size(121, 24);
            this.cmbViewLayout.TabIndex = 11;
            this.tlTip.SetToolTip(this.cmbViewLayout, "Select View Layout");
            // 
            // btnReset
            // 
            this.btnReset.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnReset.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnReset.BackgroundImage")));
            this.btnReset.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnReset.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnReset.ForeColor = System.Drawing.Color.Black;
            this.btnReset.Location = new System.Drawing.Point(3, 26);
            this.btnReset.Name = "btnReset";
            this.btnReset.Size = new System.Drawing.Size(81, 29);
            this.btnReset.TabIndex = 7;
            this.btnReset.Text = "Reset";
            this.tlTip.SetToolTip(this.btnReset, "Graph Reset");
            this.btnReset.UseVisualStyleBackColor = true;
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
            this.tlTip.SetToolTip(this.btnDirection, "Scan Direction");
            this.btnDirection.UseVisualStyleBackColor = true;
            this.btnDirection.Click += new System.EventHandler(this.btnDirection_Click);
            // 
            // ctxtMnu
            // 
            this.ctxtMnu.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.ctxtMnu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.showMeasurementCursorToolStripMenuItem});
            this.ctxtMnu.Name = "ctxtMnu";
            this.ctxtMnu.Size = new System.Drawing.Size(255, 28);
            // 
            // splitMMode
            // 
            this.splitMMode.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitMMode.Location = new System.Drawing.Point(0, 0);
            this.splitMMode.Name = "splitMMode";
            this.splitMMode.Panel2Collapsed = true;
            this.splitMMode.Size = new System.Drawing.Size(1141, 524);
            this.splitMMode.SplitterDistance = 273;
            this.splitMMode.TabIndex = 0;
            // 
            // lblFrameIdx
            // 
            this.lblFrameIdx.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.lblFrameIdx.AutoSize = true;
            this.lblFrameIdx.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblFrameIdx.Location = new System.Drawing.Point(584, 86);
            this.lblFrameIdx.Name = "lblFrameIdx";
            this.lblFrameIdx.Size = new System.Drawing.Size(17, 18);
            this.lblFrameIdx.TabIndex = 10;
            this.lblFrameIdx.Text = "0";
            // 
            // trkBar
            // 
            this.trkBar.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.trkBar.Location = new System.Drawing.Point(316, 23);
            this.trkBar.Name = "trkBar";
            this.trkBar.Size = new System.Drawing.Size(140, 56);
            this.trkBar.TabIndex = 9;
            // 
            // btnPlayPause
            // 
            this.btnPlayPause.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnPlayPause.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnPlayPause.BackgroundImage")));
            this.btnPlayPause.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnPlayPause.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnPlayPause.ForeColor = System.Drawing.Color.Black;
            this.btnPlayPause.Location = new System.Drawing.Point(825, 20);
            this.btnPlayPause.Name = "btnPlayPause";
            this.btnPlayPause.Size = new System.Drawing.Size(81, 29);
            this.btnPlayPause.TabIndex = 8;
            this.btnPlayPause.Text = "Stop";
            this.btnPlayPause.UseVisualStyleBackColor = true;
            // 
            // btnSave
            // 
            this.btnSave.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.btnSave.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnSave.BackgroundImage")));
            this.btnSave.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnSave.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnSave.ForeColor = System.Drawing.Color.Black;
            this.btnSave.Location = new System.Drawing.Point(90, 26);
            this.btnSave.Name = "btnSave";
            this.btnSave.Size = new System.Drawing.Size(81, 29);
            this.btnSave.TabIndex = 6;
            this.btnSave.Text = "Save";
            this.btnSave.UseVisualStyleBackColor = true;
            // 
            // spltGraphPanel
            // 
            this.spltGraphPanel.BackColor = System.Drawing.Color.Transparent;
            this.spltGraphPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spltGraphPanel.Location = new System.Drawing.Point(0, 0);
            this.spltGraphPanel.Name = "spltGraphPanel";
            this.spltGraphPanel.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // spltGraphPanel.Panel1
            // 
            this.spltGraphPanel.Panel1.Controls.Add(this.tblyt);
            this.spltGraphPanel.Panel1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.spltGraphPanel.Panel1Collapsed = true;
            this.spltGraphPanel.Panel1MinSize = 30;
            // 
            // spltGraphPanel.Panel2
            // 
            this.spltGraphPanel.Panel2.Controls.Add(this.splitAMode);
            this.spltGraphPanel.Size = new System.Drawing.Size(1141, 524);
            this.spltGraphPanel.SplitterDistance = 69;
            this.spltGraphPanel.SplitterWidth = 1;
            this.spltGraphPanel.TabIndex = 0;
            // 
            // tblyt
            // 
            this.tblyt.ColumnCount = 5;
            this.tblyt.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 70F));
            this.tblyt.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 300F));
            this.tblyt.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 300F));
            this.tblyt.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 300F));
            this.tblyt.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 200F));
            this.tblyt.Controls.Add(this.lblPatientName, 2, 0);
            this.tblyt.Controls.Add(this.lblPatientID, 1, 0);
            this.tblyt.Controls.Add(this.pbx, 0, 0);
            this.tblyt.Controls.Add(this.btnDirection, 0, 1);
            this.tblyt.Controls.Add(this.lblHospitalName, 3, 0);
            this.tblyt.Controls.Add(this.pnlDir, 1, 1);
            this.tblyt.Controls.Add(this.lblSampleFreq, 4, 0);
            this.tblyt.Location = new System.Drawing.Point(0, 0);
            this.tblyt.Name = "tblyt";
            this.tblyt.RowCount = 2;
            this.tblyt.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 50F));
            this.tblyt.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 50F));
            this.tblyt.Size = new System.Drawing.Size(1141, 69);
            this.tblyt.TabIndex = 0;
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
            // splitAMode
            // 
            this.splitAMode.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitAMode.Location = new System.Drawing.Point(0, 0);
            this.splitAMode.Name = "splitAMode";
            this.splitAMode.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitAMode.Panel1
            // 
            this.splitAMode.Panel1.Controls.Add(this.splitMMode);
            this.splitAMode.Panel2Collapsed = true;
            this.splitAMode.Size = new System.Drawing.Size(1141, 524);
            this.splitAMode.SplitterDistance = 208;
            this.splitAMode.TabIndex = 0;
            // 
            // spltViewer
            // 
            this.spltViewer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spltViewer.Location = new System.Drawing.Point(0, 0);
            this.spltViewer.Name = "spltViewer";
            this.spltViewer.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // spltViewer.Panel1
            // 
            this.spltViewer.Panel1.Controls.Add(this.spltGraphPanel);
            // 
            // spltViewer.Panel2
            // 
            this.spltViewer.Panel2.Controls.Add(this.cmbScanModeSelecion);
            this.spltViewer.Panel2.Controls.Add(this.cmbViewLayout);
            this.spltViewer.Panel2.Controls.Add(this.lblFrameIdx);
            this.spltViewer.Panel2.Controls.Add(this.trkBar);
            this.spltViewer.Panel2.Controls.Add(this.btnPlayPause);
            this.spltViewer.Panel2.Controls.Add(this.btnReset);
            this.spltViewer.Panel2.Controls.Add(this.btnSave);
            this.spltViewer.Panel2Collapsed = true;
            this.spltViewer.Size = new System.Drawing.Size(1141, 524);
            this.spltViewer.SplitterDistance = 403;
            this.spltViewer.SplitterWidth = 1;
            this.spltViewer.TabIndex = 8;
            // 
            // tmr
            // 
            this.tmr.Interval = 1000;
            // 
            // ucViewer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.Controls.Add(this.spltViewer);
            this.Name = "ucViewer";
            this.Size = new System.Drawing.Size(1141, 524);
            this.ctxtMnu.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitMMode)).EndInit();
            this.splitMMode.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.trkBar)).EndInit();
            this.spltGraphPanel.Panel1.ResumeLayout(false);
            this.spltGraphPanel.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.spltGraphPanel)).EndInit();
            this.spltGraphPanel.ResumeLayout(false);
            this.tblyt.ResumeLayout(false);
            this.tblyt.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pbx)).EndInit();
            this.splitAMode.Panel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitAMode)).EndInit();
            this.splitAMode.ResumeLayout(false);
            this.spltViewer.Panel1.ResumeLayout(false);
            this.spltViewer.Panel2.ResumeLayout(false);
            this.spltViewer.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.spltViewer)).EndInit();
            this.spltViewer.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ToolStripMenuItem showMeasurementCursorToolStripMenuItem;
        private System.Windows.Forms.Timer tmrM_Mode;
        private System.Windows.Forms.ToolTip tlTip;
        private System.Windows.Forms.ComboBox cmbScanModeSelecion;
        private System.Windows.Forms.ComboBox cmbViewLayout;
        private System.Windows.Forms.Button btnReset;
        private System.Windows.Forms.SaveFileDialog sfd;
        private System.Windows.Forms.ContextMenuStrip ctxtMnu;
        private System.Windows.Forms.SplitContainer splitMMode;
        private System.Windows.Forms.Label lblFrameIdx;
        private System.Windows.Forms.TrackBar trkBar;
        private System.Windows.Forms.Button btnPlayPause;
        private System.Windows.Forms.Button btnSave;
        private System.Windows.Forms.SplitContainer spltGraphPanel;
        private System.Windows.Forms.SplitContainer splitAMode;
        private System.Windows.Forms.SplitContainer spltViewer;
        private System.Windows.Forms.Timer tmr;
        private System.Windows.Forms.TableLayoutPanel tblyt;
        private System.Windows.Forms.Label lblPatientName;
        private System.Windows.Forms.Label lblPatientID;
        private System.Windows.Forms.Button btnDirection;
        private System.Windows.Forms.Panel pnlDir;
        private System.Windows.Forms.Label lblSampleFreq;
        private System.Windows.Forms.Label lblHospitalName;
        private System.Windows.Forms.PictureBox pbx;
    }
}
