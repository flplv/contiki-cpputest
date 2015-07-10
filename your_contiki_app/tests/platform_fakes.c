#include <stdio.h>
#include <net/ip/uip.h>

void
slip_arch_writeb(unsigned char c)
{
  putchar(c);
}
void
slip_arch_init(unsigned long ubr)
{
    ubr++;
}
static void
init(void)
{
}
static void
output(void)
{
}
const struct uip_fallback_interface rpl_interface = {
  init, output
};
