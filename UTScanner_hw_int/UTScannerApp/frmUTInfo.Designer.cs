
namespace UTScannerApp
{
    partial class frmUTInfo
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
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.grbImgprocParam = new System.Windows.Forms.GroupBox();
            this.label2 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.grpUTInfo = new System.Windows.Forms.GroupBox();
            this.lblApertureSize = new System.Windows.Forms.Label();
            this.lblApr = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.lblProWidth = new System.Windows.Forms.Label();
            this.lblProbeType = new System.Windows.Forms.Label();
            this.lblPType = new System.Windows.Forms.Label();
            this.lblMaxDepth = new System.Windows.Forms.Label();
            this.lblSampleFrq = new System.Windows.Forms.Label();
            this.lblMD = new System.Windows.Forms.Label();
            this.lblSF = new System.Windows.Forms.Label();
            this.spcGraph = new System.Windows.Forms.SplitContainer();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.grbImgprocParam.SuspendLayout();
            this.grpUTInfo.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.spcGraph)).BeginInit();
            this.spcGraph.SuspendLayout();
            this.SuspendLayout();
            // 
            // splitContainer1
            // 
            this.splitContainer1.BackColor = System.Drawing.Color.Black;
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.splitContainer1.Location = new System.Drawing.Point(0, 0);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.grbImgprocParam);
            this.splitContainer1.Panel1.Controls.Add(this.grpUTInfo);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.spcGraph);
            this.splitContainer1.Size = new System.Drawing.Size(325, 775);
            this.splitContainer1.SplitterDistance = 384;
            this.splitContainer1.TabIndex = 0;
            // 
            // grbImgprocParam
            // 
            this.grbImgprocParam.Controls.Add(this.label2);
            this.grbImgprocParam.Controls.Add(this.label4);
            this.grbImgprocParam.Dock = System.Windows.Forms.DockStyle.Top;
            this.grbImgprocParam.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.grbImgprocParam.ForeColor = System.Drawing.Color.White;
            this.grbImgprocParam.Location = new System.Drawing.Point(0, 245);
            this.grbImgprocParam.Name = "grbImgprocParam";
            this.grbImgprocParam.Size = new System.Drawing.Size(325, 150);
            this.grbImgprocParam.TabIndex = 1;
            this.grbImgprocParam.TabStop = false;
            this.grbImgprocParam.Text = "ImageParam";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(141, 43);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(37, 17);
            this.label2.TabIndex = 2;
            this.label2.Text = "8 bit";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(12, 43);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(110, 17);
            this.label4.TabIndex = 0;
            this.label4.Text = "Image Depth   :";
            // 
            // grpUTInfo
            // 
            this.grpUTInfo.Controls.Add(this.lblApertureSize);
            this.grpUTInfo.Controls.Add(this.lblApr);
            this.grpUTInfo.Controls.Add(this.label5);
            this.grpUTInfo.Controls.Add(this.lblProWidth);
            this.grpUTInfo.Controls.Add(this.lblProbeType);
            this.grpUTInfo.Controls.Add(this.lblPType);
            this.grpUTInfo.Controls.Add(this.lblMaxDepth);
            this.grpUTInfo.Controls.Add(this.lblSampleFrq);
            this.grpUTInfo.Controls.Add(this.lblMD);
            this.grpUTInfo.Controls.Add(this.lblSF);
            this.grpUTInfo.Dock = System.Windows.Forms.DockStyle.Top;
            this.grpUTInfo.Font = new System.Drawing.Font("Times New Roman", 10.2F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.grpUTInfo.ForeColor = System.Drawing.Color.White;
            this.grpUTInfo.Location = new System.Drawing.Point(0, 0);
            this.grpUTInfo.Name = "grpUTInfo";
            this.grpUTInfo.Size = new System.Drawing.Size(325, 245);
            this.grpUTInfo.TabIndex = 0;
            this.grpUTInfo.TabStop = false;
            this.grpUTInfo.Text = "UT Info";
            // 
            // lblApertureSize
            // 
            this.lblApertureSize.AutoSize = true;
            this.lblApertureSize.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblApertureSize.Location = new System.Drawing.Point(145, 142);
            this.lblApertureSize.Name = "lblApertureSize";
            this.lblApertureSize.Size = new System.Drawing.Size(16, 17);
            this.lblApertureSize.TabIndex = 9;
            this.lblApertureSize.Text = "0";
            // 
            // lblApr
            // 
            this.lblApr.AutoSize = true;
            this.lblApr.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblApr.Location = new System.Drawing.Point(12, 142);
            this.lblApr.Name = "lblApr";
            this.lblApr.Size = new System.Drawing.Size(123, 17);
            this.lblApr.TabIndex = 8;
            this.lblApr.Text = "Aperture Size     :";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label5.Location = new System.Drawing.Point(142, 77);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(44, 17);
            this.label5.TabIndex = 7;
            this.label5.Text = "0 mm";
            // 
            // lblProWidth
            // 
            this.lblProWidth.AutoSize = true;
            this.lblProWidth.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblProWidth.Location = new System.Drawing.Point(12, 77);
            this.lblProWidth.Name = "lblProWidth";
            this.lblProWidth.Size = new System.Drawing.Size(123, 17);
            this.lblProWidth.TabIndex = 6;
            this.lblProWidth.Text = "Probe Width       :";
            // 
            // lblProbeType
            // 
            this.lblProbeType.AutoSize = true;
            this.lblProbeType.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblProbeType.Location = new System.Drawing.Point(142, 43);
            this.lblProbeType.Name = "lblProbeType";
            this.lblProbeType.Size = new System.Drawing.Size(51, 17);
            this.lblProbeType.TabIndex = 5;
            this.lblProbeType.Text = "TypeA";
            // 
            // lblPType
            // 
            this.lblPType.AutoSize = true;
            this.lblPType.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPType.Location = new System.Drawing.Point(12, 43);
            this.lblPType.Name = "lblPType";
            this.lblPType.Size = new System.Drawing.Size(124, 17);
            this.lblPType.TabIndex = 4;
            this.lblPType.Text = "Probe Type         :";
            // 
            // lblMaxDepth
            // 
            this.lblMaxDepth.AutoSize = true;
            this.lblMaxDepth.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblMaxDepth.Location = new System.Drawing.Point(142, 215);
            this.lblMaxDepth.Name = "lblMaxDepth";
            this.lblMaxDepth.Size = new System.Drawing.Size(16, 17);
            this.lblMaxDepth.TabIndex = 3;
            this.lblMaxDepth.Text = "0";
            // 
            // lblSampleFrq
            // 
            this.lblSampleFrq.AutoSize = true;
            this.lblSampleFrq.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblSampleFrq.Location = new System.Drawing.Point(141, 109);
            this.lblSampleFrq.Name = "lblSampleFrq";
            this.lblSampleFrq.Size = new System.Drawing.Size(53, 17);
            this.lblSampleFrq.TabIndex = 2;
            this.lblSampleFrq.Text = "0 MHz";
            // 
            // lblMD
            // 
            this.lblMD.AutoSize = true;
            this.lblMD.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblMD.Location = new System.Drawing.Point(12, 181);
            this.lblMD.Name = "lblMD";
            this.lblMD.Size = new System.Drawing.Size(121, 51);
            this.lblMD.TabIndex = 1;
            this.lblMD.Text = "Samples \r\ncorresponding\r\n to Max depth    :";
            // 
            // lblSF
            // 
            this.lblSF.AutoSize = true;
            this.lblSF.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblSF.Location = new System.Drawing.Point(12, 109);
            this.lblSF.Name = "lblSF";
            this.lblSF.Size = new System.Drawing.Size(120, 17);
            this.lblSF.TabIndex = 0;
            this.lblSF.Text = "Sample Frq (fs)  :";
            // 
            // spcGraph
            // 
            this.spcGraph.Dock = System.Windows.Forms.DockStyle.Fill;
            this.spcGraph.Location = new System.Drawing.Point(0, 0);
            this.spcGraph.Name = "spcGraph";
            this.spcGraph.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // spcGraph.Panel1
            // 
            this.spcGraph.Panel1.AccessibleName = "gammaCurvePanel";
            this.spcGraph.Size = new System.Drawing.Size(325, 387);
            this.spcGraph.SplitterDistance = 108;
            this.spcGraph.TabIndex = 0;
            // 
            // frmUTInfo
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(325, 775);
            this.ControlBox = false;
            this.Controls.Add(this.splitContainer1);
            this.DockAreas = ((WeifenLuo.WinFormsUI.Docking.DockAreas)((WeifenLuo.WinFormsUI.Docking.DockAreas.DockRight | WeifenLuo.WinFormsUI.Docking.DockAreas.DockBottom)));
            this.Font = new System.Drawing.Font("Microsoft Sans Serif", 7.8F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Name = "frmUTInfo";
            this.Text = "UTInfo";
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.grbImgprocParam.ResumeLayout(false);
            this.grbImgprocParam.PerformLayout();
            this.grpUTInfo.ResumeLayout(false);
            this.grpUTInfo.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.spcGraph)).EndInit();
            this.spcGraph.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.GroupBox grpUTInfo;
        private System.Windows.Forms.Label lblMaxDepth;
        private System.Windows.Forms.Label lblSampleFrq;
        private System.Windows.Forms.Label lblMD;
        private System.Windows.Forms.Label lblSF;
        private System.Windows.Forms.GroupBox grbImgprocParam;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label lblProbeType;
        private System.Windows.Forms.Label lblPType;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label lblProWidth;
        private System.Windows.Forms.SplitContainer spcGraph;
        private System.Windows.Forms.Label lblApertureSize;
        private System.Windows.Forms.Label lblApr;
    }
}