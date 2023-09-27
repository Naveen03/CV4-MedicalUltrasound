
namespace UTScannerApp
{
    partial class ucExternalView
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
            this.lblFrameIdx = new System.Windows.Forms.Label();
            this.spltGraphPanel = new System.Windows.Forms.SplitContainer();
            ((System.ComponentModel.ISupportInitialize)(this.spltGraphPanel)).BeginInit();
            this.spltGraphPanel.Panel1.SuspendLayout();
            this.spltGraphPanel.SuspendLayout();
            this.SuspendLayout();
            // 
            // lblFrameIdx
            // 
            this.lblFrameIdx.AutoSize = true;
            this.lblFrameIdx.BackColor = System.Drawing.Color.Transparent;
            this.lblFrameIdx.ForeColor = System.Drawing.Color.White;
            this.lblFrameIdx.Location = new System.Drawing.Point(22, 9);
            this.lblFrameIdx.Margin = new System.Windows.Forms.Padding(10);
            this.lblFrameIdx.Name = "lblFrameIdx";
            this.lblFrameIdx.Size = new System.Drawing.Size(123, 18);
            this.lblFrameIdx.TabIndex = 0;
            this.lblFrameIdx.Text = "Frame ID : TEST ";
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
            this.spltGraphPanel.Panel1.Controls.Add(this.lblFrameIdx);
            this.spltGraphPanel.Panel1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.spltGraphPanel.Panel1Collapsed = true;
            this.spltGraphPanel.Size = new System.Drawing.Size(765, 611);
            this.spltGraphPanel.SplitterDistance = 39;
            this.spltGraphPanel.SplitterWidth = 1;
            this.spltGraphPanel.TabIndex = 2;
            // 
            // ucExternalView
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveCaptionText;
            this.Controls.Add(this.spltGraphPanel);
            this.Name = "ucExternalView";
            this.Size = new System.Drawing.Size(765, 611);
            this.spltGraphPanel.Panel1.ResumeLayout(false);
            this.spltGraphPanel.Panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.spltGraphPanel)).EndInit();
            this.spltGraphPanel.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label lblFrameIdx;
        private System.Windows.Forms.SplitContainer spltGraphPanel;
    }
}
