# INSTALADOR PROFESIONAL Bazar y Papelería
# Interfaz tipo "Siguiente, Siguiente, Instalar"
ECHO est� desactivado.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem
ECHO est� desactivado.
$ErrorActionPreference = "Stop"
ECHO est� desactivado.
# Variables globales
$global:currentStep = 1
$global:installPath = "$env:LOCALAPPDATA\BazarPapeleria"
$global:createDesktopShortcut = $true
$global:createStartMenuShortcut = $true
ECHO est� desactivado.
# Función para crear la ventana principal
function Create-MainWindow {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Instalador - Bazar y Papelería v2.0.0"
    $form.Size = New-Object System.Drawing.Size(500, 400)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = [System.Drawing.Color]::White
ECHO est� desactivado.
    return $form
}
ECHO est� desactivado.
# Página 1: Bienvenida
function Show-WelcomePage {
    param($form)
ECHO est� desactivado.
    $form.Controls.Clear()
ECHO est� desactivado.
    # Título
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Location = New-Object System.Drawing.Point(50, 30)
    $lblTitle.Size = New-Object System.Drawing.Size(400, 40)
    $lblTitle.Text = "Bienvenido al Instalador de Bazar y Papelería"
    $lblTitle.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $lblTitle.ForeColor = [System.Drawing.Color]::DarkBlue
    $form.Controls.Add($lblTitle)
ECHO est� desactivado.
    # Descripción
    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Location = New-Object System.Drawing.Point(50, 80)
    $lblDesc.Size = New-Object System.Drawing.Size(400, 120)
    $lblDesc.Text = "Este asistente le guiará a través del proceso de instalación del Sistema de Gestión Integral Bazar y Papelería.`n`nLa aplicación incluye:`n• Gestión completa de inventario`n• Control de usuarios y permisos`n• Respaldos automáticos`n• Interfaz moderna y fácil de usar"
    $lblDesc.Font = New-Object System.Drawing.Font("Arial", 10)
    $form.Controls.Add($lblDesc)
ECHO est� desactivado.
    # Botones
    $btnNext = New-Object System.Windows.Forms.Button
    $btnNext.Location = New-Object System.Drawing.Point(320, 320)
    $btnNext.Size = New-Object System.Drawing.Size(80, 30)
    $btnNext.Text = "Siguiente >"
    $btnNext.Add_Click({ 
        $global:currentStep = 2
        Show-DirectoryPage $form 
    })
    $form.Controls.Add($btnNext)
ECHO est� desactivado.
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Location = New-Object System.Drawing.Point(410, 320)
    $btnCancel.Size = New-Object System.Drawing.Size(80, 30)
    $btnCancel.Text = "Cancelar"
    $btnCancel.Add_Click({ $form.Close() })
    $form.Controls.Add($btnCancel)
}
ECHO est� desactivado.
# Página 2: Selección de directorio
function Show-DirectoryPage {
    param($form)
ECHO est� desactivado.
    $form.Controls.Clear()
ECHO est� desactivado.
    # Título
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Location = New-Object System.Drawing.Point(50, 30)
    $lblTitle.Size = New-Object System.Drawing.Size(400, 30)
    $lblTitle.Text = "Seleccionar Directorio de Instalación"
    $lblTitle.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($lblTitle)
ECHO est� desactivado.
    # Descripción
    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Location = New-Object System.Drawing.Point(50, 70)
    $lblDesc.Size = New-Object System.Drawing.Size(400, 40)
    $lblDesc.Text = "Seleccione la carpeta donde desea instalar Bazar y Papelería:"
    $lblDesc.Font = New-Object System.Drawing.Font("Arial", 10)
    $form.Controls.Add($lblDesc)
ECHO est� desactivado.
    # Campo de directorio
    $txtPath = New-Object System.Windows.Forms.TextBox
    $txtPath.Location = New-Object System.Drawing.Point(50, 120)
    $txtPath.Size = New-Object System.Drawing.Size(300, 25)
    $txtPath.Text = $global:installPath
    $form.Controls.Add($txtPath)
ECHO est� desactivado.
    # Botón examinar
    $btnBrowse = New-Object System.Windows.Forms.Button
    $btnBrowse.Location = New-Object System.Drawing.Point(360, 118)
    $btnBrowse.Size = New-Object System.Drawing.Size(80, 28)
    $btnBrowse.Text = "Examinar..."
    $btnBrowse.Add_Click({
        $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderDialog.Description = "Seleccione el directorio de instalación"
        $folderDialog.SelectedPath = [System.IO.Path]::GetDirectoryName($txtPath.Text)
        if ($folderDialog.ShowDialog() -eq "OK") {
            $txtPath.Text = [System.IO.Path]::Combine($folderDialog.SelectedPath, "Bazar y Papelería")
        }
    })
    $form.Controls.Add($btnBrowse)
ECHO est� desactivado.
    # Información de espacio
    $lblSpace = New-Object System.Windows.Forms.Label
    $lblSpace.Location = New-Object System.Drawing.Point(50, 160)
    $lblSpace.Size = New-Object System.Drawing.Size(400, 40)
    $lblSpace.Text = "Espacio requerido: ~25 MB`nEspacio disponible: Calculando..."
    $lblSpace.Font = New-Object System.Drawing.Font("Arial", 9)
    $form.Controls.Add($lblSpace)
ECHO est� desactivado.
    # Botones
    $btnBack = New-Object System.Windows.Forms.Button
    $btnBack.Location = New-Object System.Drawing.Point(230, 320)
    $btnBack.Size = New-Object System.Drawing.Size(80, 30)
    $btnBack.Text = "< Anterior"
    $btnBack.Add_Click({ 
        $global:currentStep = 1
        Show-WelcomePage $form 
    })
    $form.Controls.Add($btnBack)
ECHO est� desactivado.
    $btnNext = New-Object System.Windows.Forms.Button
    $btnNext.Location = New-Object System.Drawing.Point(320, 320)
    $btnNext.Size = New-Object System.Drawing.Size(80, 30)
    $btnNext.Text = "Siguiente >"
    $btnNext.Add_Click({ 
        $global:installPath = $txtPath.Text
        $global:currentStep = 3
        Show-ComponentsPage $form 
    })
    $form.Controls.Add($btnNext)
ECHO est� desactivado.
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Location = New-Object System.Drawing.Point(410, 320)
    $btnCancel.Size = New-Object System.Drawing.Size(80, 30)
    $btnCancel.Text = "Cancelar"
    $btnCancel.Add_Click({ $form.Close() })
    $form.Controls.Add($btnCancel)
}
ECHO est� desactivado.
# Página 3: Selección de componentes
function Show-ComponentsPage {
    param($form)
ECHO est� desactivado.
    $form.Controls.Clear()
ECHO est� desactivado.
    # Título
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Location = New-Object System.Drawing.Point(50, 30)
    $lblTitle.Size = New-Object System.Drawing.Size(400, 30)
    $lblTitle.Text = "Seleccionar Componentes"
    $lblTitle.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($lblTitle)
ECHO est� desactivado.
    # Descripción
    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Location = New-Object System.Drawing.Point(50, 70)
    $lblDesc.Size = New-Object System.Drawing.Size(400, 40)
    $lblDesc.Text = "Seleccione los componentes adicionales que desea instalar:"
    $lblDesc.Font = New-Object System.Drawing.Font("Arial", 10)
    $form.Controls.Add($lblDesc)
ECHO est� desactivado.
    # Checkbox acceso directo escritorio
    $chkDesktop = New-Object System.Windows.Forms.CheckBox
    $chkDesktop.Location = New-Object System.Drawing.Point(50, 120)
    $chkDesktop.Size = New-Object System.Drawing.Size(350, 25)
    $chkDesktop.Text = "Crear acceso directo en el escritorio"
    $chkDesktop.Checked = $global:createDesktopShortcut
    $chkDesktop.Add_CheckedChanged({ $global:createDesktopShortcut = $chkDesktop.Checked })
    $form.Controls.Add($chkDesktop)
ECHO est� desactivado.
    # Checkbox menú inicio
    $chkStartMenu = New-Object System.Windows.Forms.CheckBox
    $chkStartMenu.Location = New-Object System.Drawing.Point(50, 150)
    $chkStartMenu.Size = New-Object System.Drawing.Size(350, 25)
    $chkStartMenu.Text = "Crear accesos directos en el menú de inicio"
    $chkStartMenu.Checked = $global:createStartMenuShortcut
    $chkStartMenu.Add_CheckedChanged({ $global:createStartMenuShortcut = $chkStartMenu.Checked })
    $form.Controls.Add($chkStartMenu)
ECHO est� desactivado.
    # Resumen
    $lblSummary = New-Object System.Windows.Forms.Label
    $lblSummary.Location = New-Object System.Drawing.Point(50, 200)
    $lblSummary.Size = New-Object System.Drawing.Size(400, 80)
    $lblSummary.Text = "Resumen de instalación:`n• Aplicación principal: Bazar y Papelería`n• Directorio: $global:installPath`n• Componentes opcionales según selección"
    $lblSummary.Font = New-Object System.Drawing.Font("Arial", 9)
    $lblSummary.BackColor = [System.Drawing.Color]::LightGray
    $form.Controls.Add($lblSummary)
ECHO est� desactivado.
    # Botones
    $btnBack = New-Object System.Windows.Forms.Button
    $btnBack.Location = New-Object System.Drawing.Point(230, 320)
    $btnBack.Size = New-Object System.Drawing.Size(80, 30)
    $btnBack.Text = "< Anterior"
    $btnBack.Add_Click({ 
        $global:currentStep = 2
        Show-DirectoryPage $form 
    })
    $form.Controls.Add($btnBack)
ECHO est� desactivado.
    $btnInstall = New-Object System.Windows.Forms.Button
    $btnInstall.Location = New-Object System.Drawing.Point(320, 320)
    $btnInstall.Size = New-Object System.Drawing.Size(80, 30)
    $btnInstall.Text = "Instalar"
    $btnInstall.BackColor = [System.Drawing.Color]::LightGreen
    $btnInstall.Add_Click({ 
        $global:currentStep = 4
        Show-InstallPage $form 
    })
    $form.Controls.Add($btnInstall)
ECHO est� desactivado.
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Location = New-Object System.Drawing.Point(410, 320)
    $btnCancel.Size = New-Object System.Drawing.Size(80, 30)
    $btnCancel.Text = "Cancelar"
    $btnCancel.Add_Click({ $form.Close() })
    $form.Controls.Add($btnCancel)
}
ECHO est� desactivado.
# Página 4: Instalación
function Show-InstallPage {
    param($form)
ECHO est� desactivado.
    $form.Controls.Clear()
ECHO est� desactivado.
    # Título
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Location = New-Object System.Drawing.Point(50, 30)
    $lblTitle.Size = New-Object System.Drawing.Size(400, 30)
    $lblTitle.Text = "Instalando Bazar y Papelería..."
    $lblTitle.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($lblTitle)
ECHO est� desactivado.
    # Estado actual
    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Location = New-Object System.Drawing.Point(50, 80)
    $lblStatus.Size = New-Object System.Drawing.Size(400, 25)
    $lblStatus.Text = "Preparando instalación..."
    $lblStatus.Font = New-Object System.Drawing.Font("Arial", 10)
    $form.Controls.Add($lblStatus)
ECHO est� desactivado.
    # Barra de progreso
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(50, 120)
    $progressBar.Size = New-Object System.Drawing.Size(400, 25)
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Value = 0
    $form.Controls.Add($progressBar)
ECHO est� desactivado.
    # Detalles
    $lblDetails = New-Object System.Windows.Forms.Label
    $lblDetails.Location = New-Object System.Drawing.Point(50, 160)
    $lblDetails.Size = New-Object System.Drawing.Size(400, 100)
    $lblDetails.Text = ""
    $lblDetails.Font = New-Object System.Drawing.Font("Arial", 8)
    $form.Controls.Add($lblDetails)
ECHO est� desactivado.
    # Botón Finalizar (inicialmente oculto)
    $btnFinish = New-Object System.Windows.Forms.Button
    $btnFinish.Location = New-Object System.Drawing.Point(320, 320)
    $btnFinish.Size = New-Object System.Drawing.Size(80, 30)
    $btnFinish.Text = "Finalizar"
    $btnFinish.Visible = $false
    $btnFinish.Add_Click({ $form.Close() })
    $form.Controls.Add($btnFinish)
ECHO est� desactivado.
    # Iniciar instalación asíncrona
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 100
    $step = 0
ECHO est� desactivado.
    $timer.Add_Tick({
        $step++
ECHO est� desactivado.
        switch ($step) {
            1 { 
                $lblStatus.Text = "Creando directorio de instalación..."
                $progressBar.Value = 10
                try {
                    if (-not (Test-Path $global:installPath)) {
                        New-Item -Path $global:installPath -ItemType Directory -Force | Out-Null
                    }
                    $lblDetails.Text += "✓ Directorio creado: $global:installPath`n"
                } catch {
                    $lblDetails.Text += "❌ Error creando directorio: $^($_.Exception.Message^)`n"
                }
            }
            10 { 
                $lblStatus.Text = "Copiando archivos de aplicación..."
                $progressBar.Value = 30
                try {
                    $sourceDir = [System.IO.Path]::Combine($PSScriptRoot, "distributable", "bazarnicole")
                    if (Test-Path $sourceDir) {
                        Copy-Item "$sourceDir\*" $global:installPath -Recurse -Force
                        $lblDetails.Text += "✓ Archivos copiados exitosamente`n"
                    } else {
                        throw "No se encuentra el directorio fuente"
                    }
                } catch {
                    $lblDetails.Text += "❌ Error copiando archivos: $^($_.Exception.Message^)`n"
                }
            }
            20 { 
                $lblStatus.Text = "Creando accesos directos..."
                $progressBar.Value = 60
                try {
                    $WshShell = New-Object -comObject WScript.Shell
ECHO est� desactivado.
                    if ($global:createDesktopShortcut) {
                        $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Bazar y Papelería.lnk")
                        $Shortcut.TargetPath = "$global:installPath\bazarnicole.exe"
                        $Shortcut.WorkingDirectory = $global:installPath
                        $Shortcut.Description = "Sistema de Gestión Integral"
                        $Shortcut.Save()
                        $lblDetails.Text += "✓ Acceso directo en escritorio creado`n"
                    }
ECHO est� desactivado.
                    if ($global:createStartMenuShortcut) {
                        $startMenuDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Bazar y Papelería"
                        if (-not (Test-Path $startMenuDir)) {
                            New-Item -Path $startMenuDir -ItemType Directory -Force | Out-Null
                        }
                        $Shortcut = $WshShell.CreateShortcut("$startMenuDir\Bazar y Papelería.lnk")
                        $Shortcut.TargetPath = "$global:installPath\bazarnicole.exe"
                        $Shortcut.WorkingDirectory = $global:installPath
                        $Shortcut.Description = "Sistema de Gestión Integral"
                        $Shortcut.Save()
                        $lblDetails.Text += "✓ Accesos directos en menú inicio creados`n"
                    }
                } catch {
                    $lblDetails.Text += "❌ Error creando accesos directos: $^($_.Exception.Message^)`n"
                }
            }
            30 { 
                $lblStatus.Text = "Finalizando instalación..."
                $progressBar.Value = 90
            }
            35 { 
                $lblStatus.Text = "¡Instalación completada exitosamente!"
                $progressBar.Value = 100
                $lblDetails.Text += "`n✅ INSTALACIÓN COMPLETADA`n"
                $lblDetails.Text += "La aplicación se instaló en: $global:installPath`n"
                $lblDetails.Text += "Puede ejecutarla desde los accesos directos creados."
                $btnFinish.Visible = $true
                $timer.Stop()
            }
        }
    })
ECHO est� desactivado.
    $timer.Start()
}
ECHO est� desactivado.
# Iniciar el instalador
$mainForm = Create-MainWindow
Show-WelcomePage $mainForm
[void]$mainForm.ShowDialog()
