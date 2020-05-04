# LVM (Logical Volume Manager / Gerenciador de volumes lógicos)

Fornece uma série de recursos para um gerenciamento mais inteligente e flexível do espaço de armazenamento, discos e partições.
O LVM consiste em agrupar dispositivos físicos, partições, discos, dispositivos de loop (tape), para gerenciá-los de forma lógica. Isso permite que o espaço armazenado possa ser redimensionado de forma dinâmica transparente.

**Instalação dos pacotes em <nowiki>CentOS</nowiki>**

```bash
yum install -y lvm2
```

**Instalação dos pacotes em Debian**

```bash
aptitude install -y lvm2
```

## Conceitos Iniciais

Para a implementação de LVM é necessário o entendimento de alguns conceitos.

**PV (Volumes Físicos/Physical Volumes)**
Pvs são os dispositivos físicos que serão utilizados pelo LVM, as partições utilizadas, e fazem parte de um VG (Volume Group).
Quando é criado um PV, são alocados, nesse dispositivo, blocos contínuos como os blocos físicos de um HD que são chamados de PE (Extensões Fisícas/Physical Extents). Essas extensões físicas fazem com que o LVM reconheça o dispositivo como parte de si.

**VG (Grupo de Volumes/ Volume Group)**
VGs são agrupamentos de Pvs, ou seja, um conjunto de Pvs. Dentro de um VG podem haver vários PVs.

**LV (volume Lógico/Logical Volume)**
É no LV que os dados são realmente armazenados; é no LV que é criado o sistema de arquivos e é ele o dispositivo que é montado, independentemente de quais dispositivos físicos serão utilizados.

**Então:** LVM é composto por vários Pvs que são compostos por Pes. Esses Pvs são agrupados formando os VGs que por sua vez podem ou não ser agrupados. Isso resultará nos LVs onde será criado e montado o sistema de arquivo, podendo assim abrigar os dados.
Para iniciar um sistema LVM é necessária a preparação dos dispositivos de armazenamento (discos partições). Para fins didáticos, será utilizado um único disco com 4 partições, porém em ambientes de produção, para fins de performance, a utilização de múltiplos dispositivos evita a concorrência de I/O(Input/Output), melhorando.

Utilizando o fdisk ou o cfdisk crie 4 partições e o tipo da partição tem que ser Linux LVM que é o código 8E.

## Criando volumes físicos


O primeiro passo para implementação de LVM é a criação dos PVs nos dispositivos que vão fazer parte da LVM. Com esse processo são criados os PEs nesse PVs.
EX:
```bash
pvcreate –v /dev/sda12  /dev/sda13  /dev/sda14  /dev/sda15
```

Com isso os dispositivos estão preparados para serem utilizados com LVM.

Grupo de volumes é a forma em que os dispositivos (PVs) se agruparão. Isso vai depender muito do resultado final esperado, porém é possível adicionar ou remover novos PVs aos grupos, a flexibilidade desse processo é garantida.

Um bom planejamento da infraestrutura de armazenamento alinhado às políticas de aquisição de novos dispositivos de backup, de tempo de vida dos dispositivos, do aumento progressivo dos dados garantem o sucesso e evitam problemas de manutenção na implementação de LVM.

## Criando grupo de volumes


Serão criados dois grupos de volumes; um contendo 3 PVs /dev/sda12 /dev/sda13 e /dev/sda14 e outro com apenas um PV o /dev/sda15.
Os grupos de volumes são nomeados para facilitar o processo, portando é necessário dar um nome aos Vgs.
```bash
vgcreate –v vg1 /dev/sda12 /dev/sda13 /dev/sda14
```

Tem-se, então um grupo de volumes composto pelas PVs /dev/sda12 /dev/sda13 e /dev/sda14, cujo o nome é vg1.
```bash
vgcreate –v vg2 /dev/sda15
```

O outro grupo que contém apenas um PV é: /dev/sda15

Obtendo Informações sobre grupos de volumes.
Para obter informações sobre grupos de volumes existentes e quem são seus membros, utilize o comando vgdisplay.
Depois de identificados os VGs existentes, pode-se obter informações mais detalhadas sobre cada VG, utilizando o mesmo comando vgdisplay, dando como parâmetro o nome do grupo e a opção –v, de verbose.

## Expandindo e reduzindo o grupo de volumes


É possível expandir ou reduzir um grupo de volumes, ou seja, adicionar e/ou remover PVs de um grupo.

**Reduzindo um Grupo de Volumes**

Para reduzir um grupo de volumes há o comando vgreduce. Em sistemas em produção que contêm dados, é importante que seja feito um backup dos dados, antes dessa operação, para evitar a perda, por algum problema adverso, e utilizar a opção –t, de teste, que antes de reduzir o VG, testa se a integridado do VG será afetada.
```bash
vgreduce –t –v vg1 /dev/sda14
```

Se o modo teste não retornar erros então o PV pode ser removido realmente.
```bash
vgreduce –v vg1 /dev/sda14
```

## Expandindo grupo de volumes.


Quando se tem um grupo de volumes, é possível adicionar novos PVs a ele, através da ferramenta vgextend.
```bash
vgextend –v vg2 /dev/sda14
```

Portanto, foi adicionado um novo PV ao VG vg2.
OBS: Para adicionar novos dispositivos a um grupo de volume, esse dispositivo deve ser um PV, portanto é necessário utilizar o comando pvcreate /dev/dispositivo antes de executar o vgextend.

## Volumes Lógicos

Com os grupos de volumes definidos, a criação do LV(Logical Volume) pode ser feita, o volume lógico é o dispositivo pelo  qual os dados serão acessados e manipulados.

Um volume lógico pode ser composto por um ou vários grupos de volumes. Ressalta-se mais uma vez a importância do planejamento acima referido.
A criação de um volume lógico envolve alguns fatores importantes:
Nome: É por meio desse nome que o volume será referenciado para a criação do sistema de arquivos e montagem, definidos pelo parâmetro –n.
VG: Do qual será criado o LV.

Tamanho: Tamanho do volume lógico. Esse tamanho deve ser no máximo a capacidade física de armazenamento da soma dos dispositivos que formam o VG, que será criado o LV.

```bash
lvcreate –v –L  100M –n lv1 vg1
```

Com isso, foi criado um dispositivo intermediário /dev/vg1/lv1. É esse dispositivo lógico que abstrai os dispositivos físicos pelos módulos LVM, tornando os dispositivos físicos transparentes do ponto de vista do sistema de arquivos e pontos de montagem.
Do comando lvdisplay, podem-se obter informações detalhadas sobre os volumes lógicos.
```bash
lvdisplay –v /dev/vg1/lv1
```

Com o volume lógico ativado, pode-se fazer uso dele para a criação do sistema de arquivos e montagem.
```bash
mkfs.ext3 /dev/vg1/lv1
mkdir /mnt/lvm
mount /dev/vg1/lv1 /mnt/lvm
df  -Th
```

Há, agora um sistema de arquivos lógico com sistema de arquivo ext3, montado e pronto para receber dados.
Redimensionar Volumes Lógicos

Como visto acima, existe volume lógico montado, cuja flexibilidade do LVM  pode ser utilizada. Há um grupo de volumes formados por 2 discos de 300 MB e utililiza-se apenas de 100MB desses 900MB disponíveis. É nesse momento que se pode aumentar ou reduzir a capacidade de armazenamento de um volume lógico, adicionando ou reduzindo um grupo de volumes.

## Aumentando a capacidade de um volume lógico


Para aumentar a capacidade de um volume lógico é necessário que haja espaço disponível no VG; senão houver, é preciso adicionar novos PVs a esse VG.
Utilizar o sinal de + “mais” logo após a opção –L. Isso indica que o valor será acrescentado ao tamnho do LV (Tamanho Atual + Valor), se o sinal de mais não for utilizado, o LV será redimensionando para o valor especificado em –L.
```bash
lvextend –v –L +150M /dev/vg1/lv1
```

Verifique que há um volume lógico com 250MB
```bash
lvdisplay –v /dev/vg1/lv1
```

O processo acima aumentou o tamanho do volume lógico, porém, para que se possa usufruir desse espaço é preciso ajustar o sistema de arquivos para o novo
tamanho do dispositivo.

## Ajustando o sistema de arquivos.


Para redimensionar o sistema de arquivos são utilizadas as ferramentas útil-linux.
Primeiramente, é necessário desmontar o dispositivo para que esse possa ser checado e redimensionado.
```bash
umount /mnt/lvm
e2fsck –f –v /dev/vg1/lv1
```

Com o sistema de arquivos devidamente checado, é feito o redimensionamento.
```bash
resize2fs /dev/vg1/lv1
```

Vamos efetuar a montagem da partição.
```bash
mount /dev/vg1/lv1 /mnt/lvm
```

Há agora, um sistema montado com o novo tamanho do LV.

## Reduzindo o volume lógico


Para reduzir o tamanho de um volume lógico é importante, antes, fazer o ajuste do sistema de arquivos e só então reduzir o volume lógico para um tamanho um pouco maior do que o sistema de arquivo, para garantir que não ocorra a quebra do mesmo por conta da realocação de blocos.
```bash
umount /mnt/lvm
```

Faz a checagem do sistema de arquivos.
```bash
e2fsck –f –v /dev/vg1/lv1
```

Para reduzir o sistema de arquivos é necessário especificar o seu tamanho final.
```bash
resize2fs /dev/vg1/lv1 195M
```

Você também poderá utilizar o comando **resize_reiserfs** para redimensionar sistemas de arquivos ReiserFS.

Você pode utilizar o comando **xfs_growfs /dev/sda15** para redimensionar sistemas de arquivos xfs

Agora o nosso sistema de arquivo tem 195 MB.

Com o sistema de arquivo devidamente configurado, é possível fazer a redução do volume lógico, lembrando mais uma vez que é importante, no caso da redução, que se deixe uma margem de folga do tamanho do volume lógico em relação ao sistema de arquivos.

```bash
lvreduce –L 200M /dev/vg1/lv1
```
Veja que, apesar de ter uma margem de segurança é emitido um alerta e é pedido confirmação antes de o processo ser realizado.
```bash
mount /dev/vg1/lv1 /mnt/lvm
df –h
```

OBS: É muito importante, antes de fazer a redução do tamanho de um volume lógico, fazer um backup dos dados para evitar problemas. A redução do tamanho de um volume lógico não é uma operação comum.


## Criando Snapshot de volume.

Aqui vamos verificar como efetuamos o snapshot de um volume, sempre leve em consideração que vamos precisar de um espaço extra na LVM para poder armazenar o Snapshot.

Quando efetuarmos o snapshot devemos sempre ter em consideração que o snapshot vai ficar armazenado no grupo de volumes do volume que vamos tirar o snapshot. O snapshot pode ser grande ou pequeno tudo vai depender da quantidade de dados armazenados.

Vamos fazer um snapshot da lv1
```bash
lvcreate -L 3G -s -n lv1-snapshot /dev/vg1/lv1
```

Agora vamos montar a nossa snapshot
```bash
mount /dev/vg1/lv1-snapshot /mnt/snapshot
```

Se você estiver utilizando um sistema de arquivos XFS deve ser adicionada a opção nouuid na opção de montagem.
```bash
mount /dev/vg1/lv1-snapshot /mnt/snapshot -onouuid,ro
```

## Removendo um snapshot.

Se já foi efetuado o backup ou o que era necessário com o snapshot podemos remover ele para liberarmos espaço da VG

Com isso precisamos desmontar a snapshot
```bash
umount /mnt/snapshot
```

Agora podemos remover o nosso volume.
```bash
lvremove /dev/vg1/lv1-snapshot
```

Usar todo o resto do disco
```bash
lvcreate -l 100%FREE -n data1 $VGNAME
```

## Referências
- http://tldp.org/HOWTO/LVM-HOWTO/
