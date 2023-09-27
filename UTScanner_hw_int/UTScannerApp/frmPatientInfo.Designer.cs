
namespace UTScannerApp
{
    partial class frmPatientInfo
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmPatientInfo));
            this.tip = new System.Windows.Forms.ToolTip(this.components);
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.tabCtrl = new System.Windows.Forms.TabControl();
            this.tpPatientInfo = new System.Windows.Forms.TabPage();
            this.splitContainer2 = new System.Windows.Forms.SplitContainer();
            this.splitContainer3 = new System.Windows.Forms.SplitContainer();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.txtPatientID = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.txtHospitalName = new System.Windows.Forms.TextBox();
            this.label1 = new System.Windows.Forms.Label();
            this.txtDoctorInfo = new System.Windows.Forms.TextBox();
            this.numAge = new System.Windows.Forms.NumericUpDown();
            this.lblAge = new System.Windows.Forms.Label();
            this.panel1 = new System.Windows.Forms.Panel();
            this.rbtnFemale = new System.Windows.Forms.RadioButton();
            this.rbtnMale = new System.Windows.Forms.RadioButton();
            this.lblGender = new System.Windows.Forms.Label();
            this.lblBirthDate = new System.Windows.Forms.Label();
            this.lblPatientName = new System.Windows.Forms.Label();
            this.txtPatientName = new System.Windows.Forms.TextBox();
            this.dtBirthDate = new System.Windows.Forms.DateTimePicker();
            this.lblPatientID = new System.Windows.Forms.Label();
            this.cmbPatientId = new System.Windows.Forms.ComboBox();
            this.tabControl2 = new System.Windows.Forms.TabControl();
            this.tabStudyInfo = new System.Windows.Forms.TabPage();
            this.txtHistory = new System.Windows.Forms.TextBox();
            this.lblHistory = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.numWeight = new System.Windows.Forms.NumericUpDown();
            this.lblWeight = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.numHeight = new System.Windows.Forms.NumericUpDown();
            this.lblHeight = new System.Windows.Forms.Label();
            this.tpProbe = new System.Windows.Forms.TabPage();
            this.grbApplication = new System.Windows.Forms.GroupBox();
            this.grpUser = new System.Windows.Forms.GroupBox();
            this.radioButton8 = new System.Windows.Forms.RadioButton();
            this.radioButton9 = new System.Windows.Forms.RadioButton();
            this.rbtnUser1 = new System.Windows.Forms.RadioButton();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.rbtnPW = new System.Windows.Forms.RadioButton();
            this.rbtnCD = new System.Windows.Forms.RadioButton();
            this.radioButton6 = new System.Windows.Forms.RadioButton();
            this.radioButton3 = new System.Windows.Forms.RadioButton();
            this.radioButton4 = new System.Windows.Forms.RadioButton();
            this.radioButton5 = new System.Windows.Forms.RadioButton();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.rbtnMSK = new System.Windows.Forms.RadioButton();
            this.rbtnEye = new System.Windows.Forms.RadioButton();
            this.rbtnBrTH = new System.Windows.Forms.RadioButton();
            this.rbtnPOC = new System.Windows.Forms.RadioButton();
            this.rbtnNewBorn = new System.Windows.Forms.RadioButton();
            this.rbtnPaed = new System.Windows.Forms.RadioButton();
            this.rbtnABD = new System.Windows.Forms.RadioButton();
            this.rbtnGYN = new System.Windows.Forms.RadioButton();
            this.rbtnOBS = new System.Windows.Forms.RadioButton();
            this.grbxProbe = new System.Windows.Forms.GroupBox();
            this.rbtnLinear = new System.Windows.Forms.RadioButton();
            this.rbtnTR = new System.Windows.Forms.RadioButton();
            this.rbtnConvex = new System.Windows.Forms.RadioButton();
            this.btnLoad = new System.Windows.Forms.Button();
            this.btnSave = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.tabCtrl.SuspendLayout();
            this.tpPatientInfo.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).BeginInit();
            this.splitContainer2.Panel1.SuspendLayout();
            this.splitContainer2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer3)).BeginInit();
            this.splitContainer3.Panel1.SuspendLayout();
            this.splitContainer3.Panel2.SuspendLayout();
            this.splitContainer3.SuspendLayout();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numAge)).BeginInit();
            this.panel1.SuspendLayout();
            this.tabControl2.SuspendLayout();
            this.tabStudyInfo.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numWeight)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numHeight)).BeginInit();
            this.tpProbe.SuspendLayout();
            this.grbApplication.SuspendLayout();
            this.grpUser.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.grbxProbe.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.tabCtrl);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.btnLoad);
            this.splitContainer1.Panel2.Controls.Add(this.btnSave);
            this.splitContainer1.Size = new System.Drawing.Size(824, 673);
            this.splitContainer1.SplitterDistance = 588;
            this.splitContainer1.TabIndex = 4;
            // 
            // tabCtrl
            // 
            this.tabCtrl.Controls.Add(this.tpPatientInfo);
            this.tabCtrl.Controls.Add(this.tpProbe);
            this.tabCtrl.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabCtrl.Location = new System.Drawing.Point(0, 0);
            this.tabCtrl.Name = "tabCtrl";
            this.tabCtrl.SelectedIndex = 0;
            this.tabCtrl.Size = new System.Drawing.Size(824, 588);
            this.tabCtrl.TabIndex = 1;
            // 
            // tpPatientInfo
            // 
            this.tpPatientInfo.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(35)))));
            this.tpPatientInfo.Controls.Add(this.splitContainer2);
            this.tpPatientInfo.Location = new System.Drawing.Point(4, 28);
            this.tpPatientInfo.Name = "tpPatientInfo";
            this.tpPatientInfo.Padding = new System.Windows.Forms.Padding(3);
            this.tpPatientInfo.Size = new System.Drawing.Size(816, 556);
            this.tpPatientInfo.TabIndex = 0;
            this.tpPatientInfo.Text = "PatientInfo";
            // 
            // splitContainer2
            // 
            this.splitContainer2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer2.Location = new System.Drawing.Point(3, 3);
            this.splitContainer2.Name = "splitContainer2";
            this.splitContainer2.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer2.Panel1
            // 
            this.splitContainer2.Panel1.Controls.Add(this.splitContainer3);
            this.splitContainer2.Panel2Collapsed = true;
            this.splitContainer2.Size = new System.Drawing.Size(810, 550);
            this.splitContainer2.SplitterDistance = 462;
            this.splitContainer2.TabIndex = 1;
            // 
            // splitContainer3
            // 
            this.splitContainer3.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.splitContainer3.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer3.Location = new System.Drawing.Point(0, 0);
            this.splitContainer3.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.splitContainer3.Name = "splitContainer3";
            this.splitContainer3.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer3.Panel1
            // 
            this.splitContainer3.Panel1.Controls.Add(this.groupBox1);
            // 
            // splitContainer3.Panel2
            // 
            this.splitContainer3.Panel2.Controls.Add(this.tabControl2);
            this.splitContainer3.Size = new System.Drawing.Size(810, 550);
            this.splitContainer3.SplitterDistance = 249;
            this.splitContainer3.SplitterWidth = 6;
            this.splitContainer3.TabIndex = 1;
            // 
            // groupBox1
            // 
            this.groupBox1.BackColor = System.Drawing.Color.Transparent;
            this.groupBox1.Controls.Add(this.txtPatientID);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.txtHospitalName);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.txtDoctorInfo);
            this.groupBox1.Controls.Add(this.numAge);
            this.groupBox1.Controls.Add(this.lblAge);
            this.groupBox1.Controls.Add(this.panel1);
            this.groupBox1.Controls.Add(this.lblGender);
            this.groupBox1.Controls.Add(this.lblBirthDate);
            this.groupBox1.Controls.Add(this.lblPatientName);
            this.groupBox1.Controls.Add(this.txtPatientName);
            this.groupBox1.Controls.Add(this.dtBirthDate);
            this.groupBox1.Controls.Add(this.lblPatientID);
            this.groupBox1.Controls.Add(this.cmbPatientId);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox1.Location = new System.Drawing.Point(0, 0);
            this.groupBox1.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.groupBox1.Size = new System.Drawing.Size(808, 247);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            // 
            // txtPatientID
            // 
            this.txtPatientID.Enabled = false;
            this.txtPatientID.Location = new System.Drawing.Point(456, 19);
            this.txtPatientID.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.txtPatientID.Name = "txtPatientID";
            this.txtPatientID.Size = new System.Drawing.Size(173, 26);
            this.txtPatientID.TabIndex = 20;
            this.txtPatientID.Visible = false;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.ForeColor = System.Drawing.Color.White;
            this.label2.Location = new System.Drawing.Point(31, 210);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(73, 19);
            this.label2.TabIndex = 19;
            this.label2.Text = "Hospital";
            // 
            // txtHospitalName
            // 
            this.txtHospitalName.Location = new System.Drawing.Point(145, 207);
            this.txtHospitalName.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.txtHospitalName.Name = "txtHospitalName";
            this.txtHospitalName.Size = new System.Drawing.Size(177, 26);
            this.txtHospitalName.TabIndex = 18;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(452, 207);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(61, 19);
            this.label1.TabIndex = 17;
            this.label1.Text = "Doctor";
            // 
            // txtDoctorInfo
            // 
            this.txtDoctorInfo.Location = new System.Drawing.Point(551, 205);
            this.txtDoctorInfo.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.txtDoctorInfo.Name = "txtDoctorInfo";
            this.txtDoctorInfo.Size = new System.Drawing.Size(173, 26);
            this.txtDoctorInfo.TabIndex = 16;
            // 
            // numAge
            // 
            this.numAge.Location = new System.Drawing.Point(551, 139);
            this.numAge.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numAge.Name = "numAge";
            this.numAge.Size = new System.Drawing.Size(63, 26);
            this.numAge.TabIndex = 15;
            this.numAge.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            // 
            // lblAge
            // 
            this.lblAge.AutoSize = true;
            this.lblAge.ForeColor = System.Drawing.Color.White;
            this.lblAge.Location = new System.Drawing.Point(452, 140);
            this.lblAge.Name = "lblAge";
            this.lblAge.Size = new System.Drawing.Size(37, 19);
            this.lblAge.TabIndex = 14;
            this.lblAge.Text = "Age";
            // 
            // panel1
            // 
            this.panel1.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.panel1.Controls.Add(this.rbtnFemale);
            this.panel1.Controls.Add(this.rbtnMale);
            this.panel1.Location = new System.Drawing.Point(547, 87);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(238, 25);
            this.panel1.TabIndex = 13;
            // 
            // rbtnFemale
            // 
            this.rbtnFemale.AutoSize = true;
            this.rbtnFemale.ForeColor = System.Drawing.Color.White;
            this.rbtnFemale.Location = new System.Drawing.Point(117, 3);
            this.rbtnFemale.Name = "rbtnFemale";
            this.rbtnFemale.Size = new System.Drawing.Size(85, 23);
            this.rbtnFemale.TabIndex = 16;
            this.rbtnFemale.TabStop = true;
            this.rbtnFemale.Text = "Female";
            this.rbtnFemale.UseVisualStyleBackColor = true;
            // 
            // rbtnMale
            // 
            this.rbtnMale.AutoSize = true;
            this.rbtnMale.ForeColor = System.Drawing.Color.White;
            this.rbtnMale.Location = new System.Drawing.Point(32, 3);
            this.rbtnMale.Name = "rbtnMale";
            this.rbtnMale.Size = new System.Drawing.Size(68, 23);
            this.rbtnMale.TabIndex = 15;
            this.rbtnMale.TabStop = true;
            this.rbtnMale.Text = "Male";
            this.rbtnMale.UseVisualStyleBackColor = true;
            // 
            // lblGender
            // 
            this.lblGender.AutoSize = true;
            this.lblGender.ForeColor = System.Drawing.Color.White;
            this.lblGender.Location = new System.Drawing.Point(448, 86);
            this.lblGender.Name = "lblGender";
            this.lblGender.Size = new System.Drawing.Size(65, 19);
            this.lblGender.TabIndex = 12;
            this.lblGender.Text = "Gender";
            // 
            // lblBirthDate
            // 
            this.lblBirthDate.AutoSize = true;
            this.lblBirthDate.ForeColor = System.Drawing.Color.White;
            this.lblBirthDate.Location = new System.Drawing.Point(31, 140);
            this.lblBirthDate.Name = "lblBirthDate";
            this.lblBirthDate.Size = new System.Drawing.Size(88, 19);
            this.lblBirthDate.TabIndex = 11;
            this.lblBirthDate.Text = "Birth Date";
            // 
            // lblPatientName
            // 
            this.lblPatientName.AutoSize = true;
            this.lblPatientName.ForeColor = System.Drawing.Color.White;
            this.lblPatientName.Location = new System.Drawing.Point(27, 83);
            this.lblPatientName.Name = "lblPatientName";
            this.lblPatientName.Size = new System.Drawing.Size(109, 19);
            this.lblPatientName.TabIndex = 10;
            this.lblPatientName.Text = "Patient Name";
            // 
            // txtPatientName
            // 
            this.txtPatientName.Location = new System.Drawing.Point(145, 79);
            this.txtPatientName.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.txtPatientName.Name = "txtPatientName";
            this.txtPatientName.Size = new System.Drawing.Size(173, 26);
            this.txtPatientName.TabIndex = 9;
            // 
            // dtBirthDate
            // 
            this.dtBirthDate.Location = new System.Drawing.Point(149, 139);
            this.dtBirthDate.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.dtBirthDate.Name = "dtBirthDate";
            this.dtBirthDate.Size = new System.Drawing.Size(173, 26);
            this.dtBirthDate.TabIndex = 8;
            this.dtBirthDate.ValueChanged += new System.EventHandler(this.dtBirthDate_ValueChanged);
            // 
            // lblPatientID
            // 
            this.lblPatientID.AutoSize = true;
            this.lblPatientID.ForeColor = System.Drawing.Color.White;
            this.lblPatientID.Location = new System.Drawing.Point(29, 22);
            this.lblPatientID.Name = "lblPatientID";
            this.lblPatientID.Size = new System.Drawing.Size(85, 19);
            this.lblPatientID.TabIndex = 7;
            this.lblPatientID.Text = "Patient ID";
            // 
            // cmbPatientId
            // 
            this.cmbPatientId.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cmbPatientId.FormattingEnabled = true;
            this.cmbPatientId.Location = new System.Drawing.Point(147, 21);
            this.cmbPatientId.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.cmbPatientId.Name = "cmbPatientId";
            this.cmbPatientId.Size = new System.Drawing.Size(173, 27);
            this.cmbPatientId.TabIndex = 6;
            this.cmbPatientId.SelectedIndexChanged += new System.EventHandler(this.cmbPatientId_SelectedIndexChanged);
            // 
            // tabControl2
            // 
            this.tabControl2.Controls.Add(this.tabStudyInfo);
            this.tabControl2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl2.Location = new System.Drawing.Point(0, 0);
            this.tabControl2.Name = "tabControl2";
            this.tabControl2.SelectedIndex = 0;
            this.tabControl2.Size = new System.Drawing.Size(808, 293);
            this.tabControl2.TabIndex = 0;
            // 
            // tabStudyInfo
            // 
            this.tabStudyInfo.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(35)))));
            this.tabStudyInfo.Controls.Add(this.txtHistory);
            this.tabStudyInfo.Controls.Add(this.lblHistory);
            this.tabStudyInfo.Controls.Add(this.label4);
            this.tabStudyInfo.Controls.Add(this.numWeight);
            this.tabStudyInfo.Controls.Add(this.lblWeight);
            this.tabStudyInfo.Controls.Add(this.label3);
            this.tabStudyInfo.Controls.Add(this.numHeight);
            this.tabStudyInfo.Controls.Add(this.lblHeight);
            this.tabStudyInfo.Location = new System.Drawing.Point(4, 28);
            this.tabStudyInfo.Name = "tabStudyInfo";
            this.tabStudyInfo.Padding = new System.Windows.Forms.Padding(3);
            this.tabStudyInfo.Size = new System.Drawing.Size(800, 261);
            this.tabStudyInfo.TabIndex = 0;
            this.tabStudyInfo.Text = "StudyInfo";
            // 
            // txtHistory
            // 
            this.txtHistory.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.txtHistory.Location = new System.Drawing.Point(89, 120);
            this.txtHistory.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.txtHistory.Multiline = true;
            this.txtHistory.Name = "txtHistory";
            this.txtHistory.Size = new System.Drawing.Size(677, 135);
            this.txtHistory.TabIndex = 18;
            // 
            // lblHistory
            // 
            this.lblHistory.AutoSize = true;
            this.lblHistory.ForeColor = System.Drawing.Color.White;
            this.lblHistory.Location = new System.Drawing.Point(19, 120);
            this.lblHistory.Name = "lblHistory";
            this.lblHistory.Size = new System.Drawing.Size(66, 19);
            this.lblHistory.TabIndex = 22;
            this.lblHistory.Text = "History";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.ForeColor = System.Drawing.Color.White;
            this.label4.Location = new System.Drawing.Point(169, 73);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(27, 19);
            this.label4.TabIndex = 21;
            this.label4.Text = "kg";
            // 
            // numWeight
            // 
            this.numWeight.Location = new System.Drawing.Point(89, 66);
            this.numWeight.Maximum = new decimal(new int[] {
            200,
            0,
            0,
            0});
            this.numWeight.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numWeight.Name = "numWeight";
            this.numWeight.Size = new System.Drawing.Size(74, 26);
            this.numWeight.TabIndex = 20;
            this.numWeight.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            // 
            // lblWeight
            // 
            this.lblWeight.AutoSize = true;
            this.lblWeight.ForeColor = System.Drawing.Color.White;
            this.lblWeight.Location = new System.Drawing.Point(19, 69);
            this.lblWeight.Name = "lblWeight";
            this.lblWeight.Size = new System.Drawing.Size(62, 19);
            this.lblWeight.TabIndex = 19;
            this.lblWeight.Text = "Weight";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.ForeColor = System.Drawing.Color.White;
            this.label3.Location = new System.Drawing.Point(173, 31);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(31, 19);
            this.label3.TabIndex = 18;
            this.label3.Text = "cm";
            // 
            // numHeight
            // 
            this.numHeight.Location = new System.Drawing.Point(93, 24);
            this.numHeight.Maximum = new decimal(new int[] {
            200,
            0,
            0,
            0});
            this.numHeight.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numHeight.Name = "numHeight";
            this.numHeight.Size = new System.Drawing.Size(74, 26);
            this.numHeight.TabIndex = 17;
            this.numHeight.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            // 
            // lblHeight
            // 
            this.lblHeight.AutoSize = true;
            this.lblHeight.ForeColor = System.Drawing.Color.White;
            this.lblHeight.Location = new System.Drawing.Point(23, 27);
            this.lblHeight.Name = "lblHeight";
            this.lblHeight.Size = new System.Drawing.Size(60, 19);
            this.lblHeight.TabIndex = 16;
            this.lblHeight.Text = "Height";
            // 
            // tpProbe
            // 
            this.tpProbe.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(35)))));
            this.tpProbe.Controls.Add(this.grbApplication);
            this.tpProbe.Controls.Add(this.grbxProbe);
            this.tpProbe.Location = new System.Drawing.Point(4, 28);
            this.tpProbe.Name = "tpProbe";
            this.tpProbe.Padding = new System.Windows.Forms.Padding(3);
            this.tpProbe.Size = new System.Drawing.Size(816, 556);
            this.tpProbe.TabIndex = 1;
            this.tpProbe.Text = "Probe";
            // 
            // grbApplication
            // 
            this.grbApplication.Controls.Add(this.grpUser);
            this.grbApplication.Controls.Add(this.groupBox3);
            this.grbApplication.Controls.Add(this.groupBox2);
            this.grbApplication.Dock = System.Windows.Forms.DockStyle.Top;
            this.grbApplication.ForeColor = System.Drawing.Color.White;
            this.grbApplication.Location = new System.Drawing.Point(3, 70);
            this.grbApplication.Name = "grbApplication";
            this.grbApplication.Size = new System.Drawing.Size(810, 483);
            this.grbApplication.TabIndex = 1;
            this.grbApplication.TabStop = false;
            this.grbApplication.Text = "Application";
            // 
            // grpUser
            // 
            this.grpUser.Controls.Add(this.radioButton8);
            this.grpUser.Controls.Add(this.radioButton9);
            this.grpUser.Controls.Add(this.rbtnUser1);
            this.grpUser.Dock = System.Windows.Forms.DockStyle.Top;
            this.grpUser.ForeColor = System.Drawing.Color.White;
            this.grpUser.Location = new System.Drawing.Point(3, 211);
            this.grpUser.Name = "grpUser";
            this.grpUser.Size = new System.Drawing.Size(804, 85);
            this.grpUser.TabIndex = 28;
            this.grpUser.TabStop = false;
            this.grpUser.Text = "User";
            // 
            // radioButton8
            // 
            this.radioButton8.AutoSize = true;
            this.radioButton8.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.radioButton8.ForeColor = System.Drawing.Color.White;
            this.radioButton8.Location = new System.Drawing.Point(443, 40);
            this.radioButton8.Name = "radioButton8";
            this.radioButton8.Size = new System.Drawing.Size(76, 23);
            this.radioButton8.TabIndex = 18;
            this.radioButton8.Text = "User 3";
            this.radioButton8.UseVisualStyleBackColor = true;
            // 
            // radioButton9
            // 
            this.radioButton9.AutoSize = true;
            this.radioButton9.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.radioButton9.ForeColor = System.Drawing.Color.White;
            this.radioButton9.Location = new System.Drawing.Point(317, 40);
            this.radioButton9.Name = "radioButton9";
            this.radioButton9.Size = new System.Drawing.Size(76, 23);
            this.radioButton9.TabIndex = 17;
            this.radioButton9.Text = "User 2";
            this.radioButton9.UseVisualStyleBackColor = true;
            // 
            // rbtnUser1
            // 
            this.rbtnUser1.AutoSize = true;
            this.rbtnUser1.Checked = true;
            this.rbtnUser1.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnUser1.ForeColor = System.Drawing.Color.White;
            this.rbtnUser1.Location = new System.Drawing.Point(186, 40);
            this.rbtnUser1.Name = "rbtnUser1";
            this.rbtnUser1.Size = new System.Drawing.Size(55, 23);
            this.rbtnUser1.TabIndex = 16;
            this.rbtnUser1.TabStop = true;
            this.rbtnUser1.Text = "AFI";
            this.rbtnUser1.UseVisualStyleBackColor = true;
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.rbtnPW);
            this.groupBox3.Controls.Add(this.rbtnCD);
            this.groupBox3.Controls.Add(this.radioButton6);
            this.groupBox3.Controls.Add(this.radioButton3);
            this.groupBox3.Controls.Add(this.radioButton4);
            this.groupBox3.Controls.Add(this.radioButton5);
            this.groupBox3.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBox3.ForeColor = System.Drawing.Color.White;
            this.groupBox3.Location = new System.Drawing.Point(3, 126);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(804, 85);
            this.groupBox3.TabIndex = 27;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "PRESET";
            // 
            // rbtnPW
            // 
            this.rbtnPW.AutoSize = true;
            this.rbtnPW.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnPW.ForeColor = System.Drawing.Color.White;
            this.rbtnPW.Location = new System.Drawing.Point(649, 40);
            this.rbtnPW.Name = "rbtnPW";
            this.rbtnPW.Size = new System.Drawing.Size(56, 23);
            this.rbtnPW.TabIndex = 21;
            this.rbtnPW.Text = "PW";
            this.rbtnPW.UseVisualStyleBackColor = true;
            // 
            // rbtnCD
            // 
            this.rbtnCD.AutoSize = true;
            this.rbtnCD.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnCD.ForeColor = System.Drawing.Color.White;
            this.rbtnCD.Location = new System.Drawing.Point(558, 40);
            this.rbtnCD.Name = "rbtnCD";
            this.rbtnCD.Size = new System.Drawing.Size(53, 23);
            this.rbtnCD.TabIndex = 20;
            this.rbtnCD.Text = "CD";
            this.rbtnCD.UseVisualStyleBackColor = true;
            // 
            // radioButton6
            // 
            this.radioButton6.AutoSize = true;
            this.radioButton6.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.radioButton6.ForeColor = System.Drawing.Color.White;
            this.radioButton6.Location = new System.Drawing.Point(438, 40);
            this.radioButton6.Name = "radioButton6";
            this.radioButton6.Size = new System.Drawing.Size(80, 23);
            this.radioButton6.TabIndex = 19;
            this.radioButton6.Text = "F.Heart";
            this.radioButton6.UseVisualStyleBackColor = true;
            // 
            // radioButton3
            // 
            this.radioButton3.AutoSize = true;
            this.radioButton3.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.radioButton3.ForeColor = System.Drawing.Color.White;
            this.radioButton3.Location = new System.Drawing.Point(317, 40);
            this.radioButton3.Name = "radioButton3";
            this.radioButton3.Size = new System.Drawing.Size(75, 23);
            this.radioButton3.TabIndex = 18;
            this.radioButton3.Text = "Trim 3";
            this.radioButton3.UseVisualStyleBackColor = true;
            // 
            // radioButton4
            // 
            this.radioButton4.AutoSize = true;
            this.radioButton4.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.radioButton4.ForeColor = System.Drawing.Color.White;
            this.radioButton4.Location = new System.Drawing.Point(186, 40);
            this.radioButton4.Name = "radioButton4";
            this.radioButton4.Size = new System.Drawing.Size(75, 23);
            this.radioButton4.TabIndex = 17;
            this.radioButton4.Text = "Trim 2";
            this.radioButton4.UseVisualStyleBackColor = true;
            // 
            // radioButton5
            // 
            this.radioButton5.AutoSize = true;
            this.radioButton5.Checked = true;
            this.radioButton5.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.radioButton5.ForeColor = System.Drawing.Color.White;
            this.radioButton5.Location = new System.Drawing.Point(55, 40);
            this.radioButton5.Name = "radioButton5";
            this.radioButton5.Size = new System.Drawing.Size(75, 23);
            this.radioButton5.TabIndex = 16;
            this.radioButton5.TabStop = true;
            this.radioButton5.Text = "Trim 1";
            this.radioButton5.UseVisualStyleBackColor = true;
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.rbtnMSK);
            this.groupBox2.Controls.Add(this.rbtnEye);
            this.groupBox2.Controls.Add(this.rbtnBrTH);
            this.groupBox2.Controls.Add(this.rbtnPOC);
            this.groupBox2.Controls.Add(this.rbtnNewBorn);
            this.groupBox2.Controls.Add(this.rbtnPaed);
            this.groupBox2.Controls.Add(this.rbtnABD);
            this.groupBox2.Controls.Add(this.rbtnGYN);
            this.groupBox2.Controls.Add(this.rbtnOBS);
            this.groupBox2.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBox2.ForeColor = System.Drawing.Color.White;
            this.groupBox2.Location = new System.Drawing.Point(3, 22);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(804, 104);
            this.groupBox2.TabIndex = 26;
            this.groupBox2.TabStop = false;
            // 
            // rbtnMSK
            // 
            this.rbtnMSK.AutoSize = true;
            this.rbtnMSK.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnMSK.ForeColor = System.Drawing.Color.White;
            this.rbtnMSK.Location = new System.Drawing.Point(558, 66);
            this.rbtnMSK.Name = "rbtnMSK";
            this.rbtnMSK.Size = new System.Drawing.Size(66, 23);
            this.rbtnMSK.TabIndex = 34;
            this.rbtnMSK.TabStop = true;
            this.rbtnMSK.Text = "MSK";
            this.rbtnMSK.UseVisualStyleBackColor = true;
            // 
            // rbtnEye
            // 
            this.rbtnEye.AutoSize = true;
            this.rbtnEye.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnEye.ForeColor = System.Drawing.Color.White;
            this.rbtnEye.Location = new System.Drawing.Point(443, 66);
            this.rbtnEye.Name = "rbtnEye";
            this.rbtnEye.Size = new System.Drawing.Size(56, 23);
            this.rbtnEye.TabIndex = 33;
            this.rbtnEye.TabStop = true;
            this.rbtnEye.Text = "Eye";
            this.rbtnEye.UseVisualStyleBackColor = true;
            // 
            // rbtnBrTH
            // 
            this.rbtnBrTH.AutoSize = true;
            this.rbtnBrTH.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnBrTH.ForeColor = System.Drawing.Color.White;
            this.rbtnBrTH.Location = new System.Drawing.Point(317, 66);
            this.rbtnBrTH.Name = "rbtnBrTH";
            this.rbtnBrTH.Size = new System.Drawing.Size(89, 23);
            this.rbtnBrTH.TabIndex = 32;
            this.rbtnBrTH.TabStop = true;
            this.rbtnBrTH.Text = "BR/THY";
            this.rbtnBrTH.UseVisualStyleBackColor = true;
            // 
            // rbtnPOC
            // 
            this.rbtnPOC.AutoSize = true;
            this.rbtnPOC.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnPOC.ForeColor = System.Drawing.Color.White;
            this.rbtnPOC.Location = new System.Drawing.Point(186, 66);
            this.rbtnPOC.Name = "rbtnPOC";
            this.rbtnPOC.Size = new System.Drawing.Size(63, 23);
            this.rbtnPOC.TabIndex = 31;
            this.rbtnPOC.TabStop = true;
            this.rbtnPOC.Text = "POC";
            this.rbtnPOC.UseVisualStyleBackColor = true;
            // 
            // rbtnNewBorn
            // 
            this.rbtnNewBorn.AutoSize = true;
            this.rbtnNewBorn.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnNewBorn.ForeColor = System.Drawing.Color.White;
            this.rbtnNewBorn.Location = new System.Drawing.Point(558, 22);
            this.rbtnNewBorn.Name = "rbtnNewBorn";
            this.rbtnNewBorn.Size = new System.Drawing.Size(99, 23);
            this.rbtnNewBorn.TabIndex = 30;
            this.rbtnNewBorn.TabStop = true;
            this.rbtnNewBorn.Text = "New Born";
            this.rbtnNewBorn.UseVisualStyleBackColor = true;
            // 
            // rbtnPaed
            // 
            this.rbtnPaed.AutoSize = true;
            this.rbtnPaed.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnPaed.ForeColor = System.Drawing.Color.White;
            this.rbtnPaed.Location = new System.Drawing.Point(443, 22);
            this.rbtnPaed.Name = "rbtnPaed";
            this.rbtnPaed.Size = new System.Drawing.Size(71, 23);
            this.rbtnPaed.TabIndex = 29;
            this.rbtnPaed.TabStop = true;
            this.rbtnPaed.Text = "PAED";
            this.rbtnPaed.UseVisualStyleBackColor = true;
            // 
            // rbtnABD
            // 
            this.rbtnABD.AutoSize = true;
            this.rbtnABD.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnABD.ForeColor = System.Drawing.Color.White;
            this.rbtnABD.Location = new System.Drawing.Point(317, 22);
            this.rbtnABD.Name = "rbtnABD";
            this.rbtnABD.Size = new System.Drawing.Size(64, 23);
            this.rbtnABD.TabIndex = 28;
            this.rbtnABD.TabStop = true;
            this.rbtnABD.Text = "ABD";
            this.rbtnABD.UseVisualStyleBackColor = true;
            // 
            // rbtnGYN
            // 
            this.rbtnGYN.AutoSize = true;
            this.rbtnGYN.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnGYN.ForeColor = System.Drawing.Color.White;
            this.rbtnGYN.Location = new System.Drawing.Point(186, 22);
            this.rbtnGYN.Name = "rbtnGYN";
            this.rbtnGYN.Size = new System.Drawing.Size(65, 23);
            this.rbtnGYN.TabIndex = 27;
            this.rbtnGYN.TabStop = true;
            this.rbtnGYN.Text = "GYN";
            this.rbtnGYN.UseVisualStyleBackColor = true;
            // 
            // rbtnOBS
            // 
            this.rbtnOBS.AutoSize = true;
            this.rbtnOBS.Checked = true;
            this.rbtnOBS.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnOBS.ForeColor = System.Drawing.Color.White;
            this.rbtnOBS.Location = new System.Drawing.Point(55, 22);
            this.rbtnOBS.Name = "rbtnOBS";
            this.rbtnOBS.Size = new System.Drawing.Size(62, 23);
            this.rbtnOBS.TabIndex = 26;
            this.rbtnOBS.TabStop = true;
            this.rbtnOBS.Text = "OBS";
            this.rbtnOBS.UseVisualStyleBackColor = true;
            // 
            // grbxProbe
            // 
            this.grbxProbe.Controls.Add(this.rbtnLinear);
            this.grbxProbe.Controls.Add(this.rbtnTR);
            this.grbxProbe.Controls.Add(this.rbtnConvex);
            this.grbxProbe.Dock = System.Windows.Forms.DockStyle.Top;
            this.grbxProbe.ForeColor = System.Drawing.Color.White;
            this.grbxProbe.Location = new System.Drawing.Point(3, 3);
            this.grbxProbe.Name = "grbxProbe";
            this.grbxProbe.Size = new System.Drawing.Size(810, 67);
            this.grbxProbe.TabIndex = 0;
            this.grbxProbe.TabStop = false;
            this.grbxProbe.Text = "ProbeType";
            // 
            // rbtnLinear
            // 
            this.rbtnLinear.AutoSize = true;
            this.rbtnLinear.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnLinear.ForeColor = System.Drawing.Color.White;
            this.rbtnLinear.Location = new System.Drawing.Point(561, 25);
            this.rbtnLinear.Name = "rbtnLinear";
            this.rbtnLinear.Size = new System.Drawing.Size(74, 23);
            this.rbtnLinear.TabIndex = 18;
            this.rbtnLinear.TabStop = true;
            this.rbtnLinear.Text = "Linear";
            this.rbtnLinear.UseVisualStyleBackColor = true;
            this.rbtnLinear.CheckedChanged += new System.EventHandler(this.rbtnLinear_CheckedChanged);
            // 
            // rbtnTR
            // 
            this.rbtnTR.AutoSize = true;
            this.rbtnTR.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnTR.ForeColor = System.Drawing.Color.White;
            this.rbtnTR.Location = new System.Drawing.Point(366, 25);
            this.rbtnTR.Name = "rbtnTR";
            this.rbtnTR.Size = new System.Drawing.Size(75, 23);
            this.rbtnTR.TabIndex = 17;
            this.rbtnTR.TabStop = true;
            this.rbtnTR.Text = "TV/TR";
            this.rbtnTR.UseVisualStyleBackColor = true;
            this.rbtnTR.CheckedChanged += new System.EventHandler(this.rbtnTR_CheckedChanged);
            // 
            // rbtnConvex
            // 
            this.rbtnConvex.AutoSize = true;
            this.rbtnConvex.Checked = true;
            this.rbtnConvex.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.rbtnConvex.ForeColor = System.Drawing.Color.White;
            this.rbtnConvex.Location = new System.Drawing.Point(142, 25);
            this.rbtnConvex.Name = "rbtnConvex";
            this.rbtnConvex.Size = new System.Drawing.Size(81, 23);
            this.rbtnConvex.TabIndex = 16;
            this.rbtnConvex.TabStop = true;
            this.rbtnConvex.Text = "Convex";
            this.rbtnConvex.UseVisualStyleBackColor = true;
            this.rbtnConvex.CheckedChanged += new System.EventHandler(this.rbtnConvex_CheckedChanged);
            // 
            // btnLoad
            // 
            this.btnLoad.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnLoad.BackgroundImage")));
            this.btnLoad.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnLoad.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnLoad.ForeColor = System.Drawing.Color.Black;
            this.btnLoad.Location = new System.Drawing.Point(448, 19);
            this.btnLoad.Name = "btnLoad";
            this.btnLoad.Size = new System.Drawing.Size(114, 32);
            this.btnLoad.TabIndex = 7;
            this.btnLoad.Text = "Load";
            this.btnLoad.UseVisualStyleBackColor = true;
            this.btnLoad.Click += new System.EventHandler(this.btnLoad_Click);
            // 
            // btnSave
            // 
            this.btnSave.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("btnSave.BackgroundImage")));
            this.btnSave.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.btnSave.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnSave.ForeColor = System.Drawing.Color.Black;
            this.btnSave.Location = new System.Drawing.Point(294, 19);
            this.btnSave.Name = "btnSave";
            this.btnSave.Size = new System.Drawing.Size(85, 32);
            this.btnSave.TabIndex = 6;
            this.btnSave.Text = "Save";
            this.btnSave.UseVisualStyleBackColor = true;
            this.btnSave.Click += new System.EventHandler(this.btnSave_Click);
            // 
            // frmPatientInfo
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 19F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(35)))));
            this.ClientSize = new System.Drawing.Size(824, 673);
            this.Controls.Add(this.splitContainer1);
            this.Font = new System.Drawing.Font("Times New Roman", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.MaximizeBox = false;
            this.Name = "frmPatientInfo";
            this.SizeGripStyle = System.Windows.Forms.SizeGripStyle.Hide;
            this.Text = "Patient Info";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.frmPatientInfo_FormClosing);
            this.Load += new System.EventHandler(this.frmPatientInfo_Load);
            this.Shown += new System.EventHandler(this.frmPatientInfo_Shown);
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.tabCtrl.ResumeLayout(false);
            this.tpPatientInfo.ResumeLayout(false);
            this.splitContainer2.Panel1.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer2)).EndInit();
            this.splitContainer2.ResumeLayout(false);
            this.splitContainer3.Panel1.ResumeLayout(false);
            this.splitContainer3.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer3)).EndInit();
            this.splitContainer3.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numAge)).EndInit();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.tabControl2.ResumeLayout(false);
            this.tabStudyInfo.ResumeLayout(false);
            this.tabStudyInfo.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numWeight)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numHeight)).EndInit();
            this.tpProbe.ResumeLayout(false);
            this.grbApplication.ResumeLayout(false);
            this.grpUser.ResumeLayout(false);
            this.grpUser.PerformLayout();
            this.groupBox3.ResumeLayout(false);
            this.groupBox3.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.grbxProbe.ResumeLayout(false);
            this.grbxProbe.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.ToolTip tip;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.TabControl tabCtrl;
        private System.Windows.Forms.TabPage tpPatientInfo;
        private System.Windows.Forms.SplitContainer splitContainer2;
        private System.Windows.Forms.SplitContainer splitContainer3;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.TextBox txtPatientID;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox txtHospitalName;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox txtDoctorInfo;
        private System.Windows.Forms.NumericUpDown numAge;
        private System.Windows.Forms.Label lblAge;
        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.RadioButton rbtnFemale;
        private System.Windows.Forms.RadioButton rbtnMale;
        private System.Windows.Forms.Label lblGender;
        private System.Windows.Forms.Label lblBirthDate;
        private System.Windows.Forms.Label lblPatientName;
        private System.Windows.Forms.TextBox txtPatientName;
        private System.Windows.Forms.DateTimePicker dtBirthDate;
        private System.Windows.Forms.Label lblPatientID;
        private System.Windows.Forms.ComboBox cmbPatientId;
        private System.Windows.Forms.TabControl tabControl2;
        private System.Windows.Forms.TabPage tabStudyInfo;
        private System.Windows.Forms.TextBox txtHistory;
        private System.Windows.Forms.Label lblHistory;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.NumericUpDown numWeight;
        private System.Windows.Forms.Label lblWeight;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.NumericUpDown numHeight;
        private System.Windows.Forms.Label lblHeight;
        private System.Windows.Forms.TabPage tpProbe;
        private System.Windows.Forms.Button btnLoad;
        private System.Windows.Forms.Button btnSave;
        private System.Windows.Forms.GroupBox grbxProbe;
        private System.Windows.Forms.RadioButton rbtnLinear;
        private System.Windows.Forms.RadioButton rbtnTR;
        private System.Windows.Forms.RadioButton rbtnConvex;
        private System.Windows.Forms.GroupBox grbApplication;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.RadioButton rbtnNewBorn;
        private System.Windows.Forms.RadioButton rbtnPaed;
        private System.Windows.Forms.RadioButton rbtnABD;
        private System.Windows.Forms.RadioButton rbtnGYN;
        private System.Windows.Forms.RadioButton rbtnOBS;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.RadioButton radioButton6;
        private System.Windows.Forms.RadioButton radioButton3;
        private System.Windows.Forms.RadioButton radioButton4;
        private System.Windows.Forms.RadioButton radioButton5;
        private System.Windows.Forms.RadioButton rbtnPOC;
        private System.Windows.Forms.RadioButton rbtnMSK;
        private System.Windows.Forms.RadioButton rbtnEye;
        private System.Windows.Forms.RadioButton rbtnBrTH;
        private System.Windows.Forms.RadioButton rbtnPW;
        private System.Windows.Forms.RadioButton rbtnCD;
        private System.Windows.Forms.GroupBox grpUser;
        private System.Windows.Forms.RadioButton radioButton8;
        private System.Windows.Forms.RadioButton radioButton9;
        private System.Windows.Forms.RadioButton rbtnUser1;
    }
}