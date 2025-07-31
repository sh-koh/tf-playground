resource "libvirt_volume" "workers" {
  count  = 3
  name   = "workers-${count.index + 1}"
  pool   = "img"
  base_volume_id = libvirt_volume.debian12.id
}

resource "libvirt_cloudinit_disk" "cloudinit_workers" {
  count          = 3
  name           = "worker-${count.index + 1}.iso"
  pool           = "img"
  user_data      = templatefile("${path.module}/cloud_init.cfg", { hostname = "worker-${count.index + 1}" })
  network_config = templatefile("${path.module}/network_config.cfg", {
    ip_address    = "192.168.10.${31 + count.index}"
    ip_gateway    = "192.168.10.1"
    ip_nameserver = "192.168.10.1"
  })
}

resource "libvirt_domain" "workers" {
  count     = 3
  name      = "worker-${count.index + 1}"
  cloudinit = libvirt_cloudinit_disk.cloudinit_workers[count.index].id
  memory    = 2048
  vcpu      = 2
  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_id   = libvirt_network.testing.id
    hostname     = "worker-${count.index + 1}"
    addresses    = ["192.168.10.${31 + count.index}"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.workers[count.index].id
  }
}
