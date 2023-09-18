/* gkrellm-entropy.c      - requires GKrellM 2.0.0 or better

       Monitor entropy available for /dev/random and /dev/urandom
       Copyright (C) 2006 Stu Gott

       You may use and distribute this software under the terms of the
       GNU General Public License, version 2 or later.

       This program is distributed in the hope that it will be useful,
       but WITHOUT ANY WARRANTY; without even the implied warranty of
       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
       GNU General Public License for more details.

       You should have received a copy of the GNU General Public License
       along with this program; if not, write to the Free Software Foundation,
       Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#include <stdio.h>
#include <stdlib.h>

#include <gkrellm2/gkrellm.h>

#define	CONFIG_NAME	"GkrellmEntropy"
#define	STYLE_NAME	"gkrellm_entropy"

#define ENT_SIZE_PATH "/proc/sys/kernel/random/poolsize"
#define ENT_PATH "/proc/sys/kernel/random/entropy_avail"


static GkrellmMonitor *monitor;
static GkrellmPanel   *panel;
static GkrellmKrell   *krell;
static GkrellmTicks   *pGK;
static gint           style_id;

static void
update_plugin()
{
  FILE *fd;
  static char buf[255];
  fd = fopen(ENT_PATH, "r");
  fread(buf, 1, 255, fd);
  fclose(fd);
  gkrellm_update_krell(panel, krell, atoi(buf));
  gkrellm_draw_panel_layers(panel);
}

static gint
panel_expose_event(GtkWidget *widget, GdkEventExpose *ev)
{
  gdk_draw_pixmap(widget->window,
		  widget->style->fg_gc[GTK_WIDGET_STATE (widget)],
		  panel->pixmap, ev->area.x, ev->area.y,
		  ev->area.x, ev->area.y,
		  ev->area.width, ev->area.height);
  return FALSE;
}

static void
create_plugin(GtkWidget *vbox, gint first_create)
{
  GkrellmStyle    *style;
  GkrellmPiximage *krell_image;
  FILE *fd;
  static char buf[255];
  if (first_create)
    panel = gkrellm_panel_new0();
  style = gkrellm_meter_style(style_id);
  krell_image = gkrellm_krell_meter_piximage(style_id);
  krell = gkrellm_create_krell(panel, krell_image, style);
  gkrellm_monotonic_krell_values(krell, FALSE);

  fd = fopen(ENT_SIZE_PATH, "r");
  fread(buf, 1, 255, fd);
  fclose(fd);
  gkrellm_set_krell_full_scale(krell, atoi(buf), 1);

  gkrellm_panel_configure(panel, "Entropy", style);
  gkrellm_panel_create(vbox, monitor, panel);

  if (first_create)
    g_signal_connect(G_OBJECT (panel->drawing_area), "expose_event",
		     G_CALLBACK(panel_expose_event), NULL);
}

static GkrellmMonitor	plugin_mon	=
  {
    CONFIG_NAME,
    0,
    create_plugin,
    update_plugin,
    NULL,
    NULL,

    NULL,
    NULL,
    NULL,

    NULL,
    NULL,
    NULL,

    MON_MAIL,

    NULL,
    NULL
  };

GkrellmMonitor *
gkrellm_init_plugin(void)
{
  pGK = gkrellm_ticks();
  style_id = gkrellm_add_meter_style(&plugin_mon, STYLE_NAME);
  monitor = &plugin_mon;
  return &plugin_mon;
}
