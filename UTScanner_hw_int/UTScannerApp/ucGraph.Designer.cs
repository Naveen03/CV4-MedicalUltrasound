
namespace UTScannerApp
{
    partial class ucGraph
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
            this.xyPlot = new OxyPlot.WindowsForms.PlotView();
            this.SuspendLayout();
            // 
            // xyPlot
            // 
            this.xyPlot.BackColor = System.Drawing.Color.Black;
            this.xyPlot.Dock = System.Windows.Forms.DockStyle.Fill;
            this.xyPlot.Location = new System.Drawing.Point(0, 0);
            this.xyPlot.Margin = new System.Windows.Forms.Padding(4);
            this.xyPlot.Name = "xyPlot";
            this.xyPlot.PanCursor = System.Windows.Forms.Cursors.Hand;
            this.xyPlot.Size = new System.Drawing.Size(377, 324);
            this.xyPlot.TabIndex = 8;
            this.xyPlot.ZoomHorizontalCursor = System.Windows.Forms.Cursors.SizeWE;
            this.xyPlot.ZoomRectangleCursor = System.Windows.Forms.Cursors.SizeNWSE;
            this.xyPlot.ZoomVerticalCursor = System.Windows.Forms.Cursors.SizeNS;
            // 
            // ucGraph
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.xyPlot);
            this.Name = "ucGraph";
            this.Size = new System.Drawing.Size(377, 324);
            this.ResumeLayout(false);

        }

        #endregion

        public OxyPlot.WindowsForms.PlotView xyPlot;
    }
}
