{include file='globalheader.tpl' Validator=true}

<div class="page-profile">

    <div id="profile-box" class="default-box card shadow col-12 col-sm-8 mx-auto">

        <form method="post" ajaxAction="{ProfileActions::Update}" id="form-profile" class="was-validated"
            action="{$smarty.server.SCRIPT_NAME}" role="form" data-bv-submitbuttons='button[type="submit"]'
            data-bv-onerror="enableButton" data-bv-onsuccess="enableButton" data-bv-live="enabled">

            <div class="card-body">
                <h1 class="text-center border-bottom mb-2">{translate key=EditProfile}</h1>

                <div class="d-none alert alert-success" role="alert" id="profileUpdatedMessage">
                    <i class="bi bi-check-circle-fill text-success"></i> {translate key=YourProfileWasUpdated}
                </div>

                <div class="validationSummary alert alert-danger d-none" id="validationErrors">
                    <ul>
                        {async_validator id="fname" key="FirstNameRequired"}
                        {async_validator id="lname" key="LastNameRequired"}
                        {async_validator id="username" key="UserNameRequired"}
                        {async_validator id="emailformat" key="ValidEmailRequired"}
                        {async_validator id="uniqueemail" key="UniqueEmailRequired"}
                        {async_validator id="uniqueusername" key="UniqueUsernameRequired"}
                        {async_validator id="phoneRequired" key="PhoneRequired"}
                        {async_validator id="positionRequired" key="PositionRequired"}
                        {async_validator id="organizationRequired" key="OrganizationRequired"}
                        {async_validator id="additionalattributes" key=""}
                    </ul>
                </div>

                <div class="row gy-2">
                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="username">{translate key="Username"}</label>
                            {if $AllowUsernameChange}
                                {textbox name="USERNAME" value="Username" required="required" data-bv-notempty="true" autofocus="autofocus" data-bv-notempty-message="{translate key=UserNameRequired}"}
                            {else}
                                <span>{$Username}</span>
                                <input type="hidden" {formname key=USERNAME} value="{$Username}" />
                            {/if}
                        </div>
                    </div>

                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="email">{translate key="Email"}</label>
                            {if $AllowEmailAddressChange}
                                {textbox type="email" name="EMAIL" class="input" value="Email" required="required" data-bv-notempty="true" data-bv-notempty-message="{translate key=ValidEmailRequired}"
                                data-bv-emailaddress="true"
                                data-bv-emailaddress-message="{translate key=ValidEmailRequired}" }
                            {else}
                                <span>{$Email}</span>
                                <input type="hidden" {formname key=EMAIL} value="{$Email}" />
                            {/if}
                        </div>
                    </div>

                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="fname">{translate key="FirstName"}</label>
                            {if $AllowNameChange}
                                {textbox name="FIRST_NAME" class="input" value="FirstName" required="required" data-bv-notempty="true" data-bv-notempty-message="{translate key=FirstNameRequired}"}
                            {else}
                                <span>{$FirstName}</span>
                                <input type="hidden" {formname key=FIRST_NAME} value="{$FirstName}" />
                            {/if}
                        </div>
                    </div>

                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="lname">{translate key="LastName"}</label>
                            {if $AllowNameChange}
                                {textbox name="LAST_NAME" class="input" value="LastName" required="required" data-bv-notempty="true" data-bv-notempty-message="{translate key=LastNameRequired}"}
                            {else}
                                <span>{$LastName}</span>
                                <input type="hidden" {formname key=LAST_NAME} value="{$LastName}" />
                            {/if}
                        </div>
                    </div>

                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="homepage">{translate key="DefaultPage"}</label>
                            <select {formname key='DEFAULT_HOMEPAGE'} id="homepage" class="form-select">
                                {html_options values=$HomepageValues output=$HomepageOutput selected=$Homepage}
                            </select>
                        </div>

                    </div>
                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="timezoneDropDown">{translate key="Timezone"}</label>
                            <select {formname key='TIMEZONE'} class="form-select" id="timezoneDropDown">
                                {html_options values=$TimezoneValues output=$TimezoneOutput selected=$Timezone}
                            </select>
                        </div>
                    </div>

                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="phone">{translate key="Phone"}</label>
                            {if $AllowPhoneChange}
                                <input type="text" id="phone" {formname key="PHONE"} class="form-control" size="20"
                                    value="{$Phone}" {if $RequirePhone}required="required" data-bv-notempty="true"
                                    data-bv-notempty-message="{translate key=PhoneRequired}" {/if} />
                            {else}
                                <span>{$Phone}</span>
                                <input type="hidden" {formname key=PHONE} value="{$Phone}" />
                            {/if}
                        </div>
                    </div>

                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="txtOrganization">{translate key="Organization"}</label>
                            {if $AllowOrganizationChange}
                                <input type="text" id="txtOrganization" {formname key="ORGANIZATION"} class="form-control"
                                    size="20" value="{$Organization}" {if $RequireOrganization}required="required"
                                        data-bv-notempty="true" data-bv-notempty-message="{translate key=OrganizationRequired}"
                                    {/if} />
                            {else}
                                <span>{$Organization}</span>
                                <input type="hidden" {formname key=ORGANIZATION} value="{$Organization}" />
                            {/if}
                        </div>
                    </div>

                    <div class="col-12 col-sm-6">
                        <div class="form-group">
                            <label class="reg fw-bold" for="txtPosition">{translate key="Position"}</label>
                            {if $AllowPositionChange}
                                <input type="text" id="txtPosition" {formname key="POSITION"} class="form-control" size="20"
                                    value="{$Position}" {if $RequirePosition}required="required" data-bv-notempty="true"
                                    data-bv-notempty-message="{translate key=PositionRequired}" {/if} />
                            {else}
                                <span>{$Position}</span>
                                <input type="hidden" {formname key=POSITION} value="{$Position}" />
                            {/if}
                        </div>
                    </div>

                    <div class="col-12 col-sm-6">
                        <div class="form-group form-check mb-2">
                            <input type="checkbox"
                                   class="form-check-input"
                                   id="totp_enabled"
                                   name="TOTP_ENABLED"
                                   {if $TotpEnabled}checked{/if}>
                            <label class="form-check-label fw-bold" for="totp_enabled">
                                {translate key="EnableTotp"}
                            </label>
                            <div class="form-text">
                                {translate key="TotpHelp"}
                            </div>
                        </div>
                        <input type="hidden" name="TOTP_SECRET" id="inputTotpSecret" value="">
                        {if $TotpEnabled}
                            <div class="alert alert-info mt-2">
                                {translate key="TotpEnabledInfo"}
                            </div>
                        {else}
                            <div class="alert alert-warning mt-2">
                                {translate key="TotpDisabledInfo"}
                            </div>
                        {/if}
                    </div>

                    <!-- Section QR Code TOTP -->
                    {if $ShowTotpQrCode}
                        <div class="col-12">
                            <div class="card border-primary">
                                <div class="card-header bg-primary text-white">
                                    <h5 class="mb-0"><i class="bi bi-qr-code me-2"></i>{translate key="TotpSetupTitle"}</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <h6>{translate key="TotpSetupInstructions"}</h6>
                                            <ol class="mb-3">
                                                <li>{translate key="TotpStep1"}</li>
                                                <li>{translate key="TotpStep2"}</li>
                                                <li>{translate key="TotpStep3"}</li>
                                                <li>{translate key="TotpStep4"}</li>
                                            </ol>
                                            <div class="alert alert-warning">
                                                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                                                {translate key="TotpSecurityWarning"}
                                            </div>
                                        </div>
                                        <div class="col-md-6 text-center">
                                            <div class="qr-code-container">
                                                <img src="{$TotpQrCodeUrl}" alt="QR Code TOTP" class="img-fluid border" style="max-width: 200px;">
                                            </div>
                                            <div class="mt-2">
                                                <small class="text-muted">{translate key="TotpSecretLabel"}</small>
                                                <div class="input-group input-group-sm mt-1">
                                                    <input type="text" class="form-control font-monospace" value="{$TotpSecret}" readonly id="totpSecret">
                                                    <button class="btn btn-outline-secondary" type="button" onclick="copyToClipboard('totpSecret')">
                                                        <i class="bi bi-clipboard"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    {/if}

                    {if $Attributes|default:array()|count > 0}
                        {foreach from=$Attributes item=attribute name=attributeLoop}
                            <div class="col-12 col-sm-6">
                                {control type="AttributeControl" attribute=$attribute}
                            </div>
                        {/foreach}
                    {/if}

                    <div class="d-grid mt-3">
                        <button type="submit" class="update btn btn-primary btn-block" name="{Actions::SAVE}"
                            id="btnUpdate">
                            {translate key='Update'}
                        </button>
                    </div>
                </div>
            </div>
            {csrf_token}
        </form>
    </div>
    {setfocus key='FIRST_NAME'}

    {include file="javascript-includes.tpl" Validator=true}
    {jsfile src="ajax-helpers.js"}
    {jsfile src="autocomplete.js"}
    {jsfile src="profile.js"}

    <script type="text/javascript">
        var userEmail = "{$Email}";
    </script>
    {literal}
    <script type="text/javascript">
        function enableButton() {
            $('#form-profile').find('button').removeAttr('disabled');
        }

        $(document).ready(function() {
            var profilePage = new Profile();
            profilePage.init();

            var profileForm = $('#form-profile');

            profileForm
                .on('init.field.bv', function(e, data) {
                    var $parent = data.element.parents('.form-group');
                    var $icon = $parent.find('.form-control-feedback[data-bv-icon-for="' + data.field +
                        '"]');
                    var validators = data.bv.getOptions(data.field).validators;

                    if (validators.notEmpty) {
                        $icon.addClass('bi bi-asterisk').show();
                    }
                })
                .off('success.form.bv')
                .on('success.form.bv', function(e) {
                    e.preventDefault();
                });

            profileForm.bootstrapValidator();

            $('#txtOrganization').orgAutoComplete("ajax/autocomplete.php?type={AutoCompleteType::Organization}");
        });

        function copyToClipboard(elementId) {
            var element = document.getElementById(elementId);
            element.select();
            element.setSelectionRange(0, 99999); // Pour les appareils mobiles
            document.execCommand('copy');
            
            // Feedback visuel
            var button = element.nextElementSibling;
            var originalIcon = button.innerHTML;
            button.innerHTML = '<i class="bi bi-check"></i>';
            button.classList.remove('btn-outline-secondary');
            button.classList.add('btn-success');
            
            setTimeout(function() {
                button.innerHTML = originalIcon;
                button.classList.remove('btn-success');
                button.classList.add('btn-outline-secondary');
            }, 2000);
        }

        // Gestion de l'activation TOTP
        $(document).ready(function() {
            $('#totp_enabled').change(function() {
                if ($(this).is(':checked')) {
                    // Charger le QR code TOTP directement depuis Symfony
                    $.ajax({
                        url: '/authentication/2fa/generate-qr',
                        method: 'POST',
                        contentType: 'application/json',
                        data: JSON.stringify({
                            email: userEmail // Email de l'utilisateur connecté
                        }),
                        success: function(response) {
                            if (response.success) {
                                // Remplir le champ caché avec le secret
                                $('#inputTotpSecret').val(response.secret);
                                
                                // Afficher la section QR code
                                var qrSection = `
                                    <div class="col-12">
                                        <div class="card border-primary">
                                            <div class="card-header bg-primary text-white">
                                                <h5 class="mb-0"><i class="bi bi-qr-code me-2"></i>Configuration de l'authentification à deux facteurs</h5>
                                            </div>
                                            <div class="card-body">
                                                <div class="row">
                                                    <div class="col-md-6">
                                                        <h6>Instructions de configuration</h6>
                                                        <ol class="mb-3">
                                                            <li>Téléchargez une application d'authentification (Google Authenticator, Authy, etc.)</li>
                                                            <li>Scannez le QR code ci-contre avec votre application</li>
                                                            <li>Entrez le code généré par l'application pour vérifier</li>
                                                            <li>Sauvegardez votre profil pour activer le TOTP</li>
                                                        </ol>
                                                        <div class="alert alert-warning">
                                                            <i class="bi bi-exclamation-triangle-fill me-2"></i>
                                                            <strong>Important :</strong> Gardez ce secret en lieu sûr. Il vous sera nécessaire si vous changez d'appareil.
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6 text-center">
                                                        <div class="qr-code-container">
                                                            <img src="${response.qr_code_url}" alt="QR Code TOTP" class="img-fluid border" style="max-width: 200px;">
                                                        </div>
                                                        <div class="mt-2">
                                                            <small class="text-muted">Secret TOTP (si scan impossible)</small>
                                                            <div class="input-group input-group-sm mt-1">
                                                                <input type="text" class="form-control font-monospace" value="${response.secret}" readonly id="totp_secret">
                                                                <button class="btn btn-outline-secondary" type="button" onclick="copyToClipboard('totp_secret')">
                                                                    <i class="bi bi-clipboard"></i>
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                `;
                                
                                // Insérer la section après la case à cocher
                                if ($('#totp_enabled').closest('.col-12').next('.col-12').length === 0) {
                                    $('#totp_enabled').closest('.col-12').after(qrSection);
                                }
                            } else {
                                alert('Erreur lors de la génération du QR code : ' + (response.message || 'Erreur inconnue'));
                                $(this).prop('checked', false);
                            }
                        },
                        error: function(xhr, status, error) {
                            console.error('Erreur AJAX:', xhr.responseText);
                            alert('Erreur lors de la génération du QR code. Vérifiez que le serveur Symfony est démarré.');
                            $(this).prop('checked', false);
                        }
                    });
                } else {
                    // Supprimer la section QR code et vider le secret
                    $('#totp_enabled').closest('.col-12').next('.col-12').remove();
                    $('#inputTotpSecret').val('');
                }
            });
        });
    </script>
    {/literal}

    <div class="modal" id="waitModal" tabindex="-1" role="dialog" aria-labelledby="waitModalLabel"
        data-bs-backdrop="static" aria-hidden="true">
        {include file="wait-box.tpl" translateKey='Working'}
    </div>

</div>
{include file='globalfooter.tpl'}