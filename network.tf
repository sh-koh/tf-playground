resource "libvirt_network" "testing" {
  name      = "testing"
  mode      = "nat"
  domain    = "testing.local"
  addresses = ["192.168.10.0/24"]
  autostart = true
  dhcp {
    enabled = false
  }
}

