-- plsql/01_exceptions.sql
-- Run as GLPI_OWNER on BOTH nodes

CREATE OR REPLACE PACKAGE PKG_EXCEPTIONS AS
    c_site_incompatible       CONSTANT PLS_INTEGER := -20001;
    c_materiel_deja_attribue  CONSTANT PLS_INTEGER := -20002;
    c_mac_dupliquee           CONSTANT PLS_INTEGER := -20003;
    c_ip_dupliquee            CONSTANT PLS_INTEGER := -20004;
    c_attribution_invalide    CONSTANT PLS_INTEGER := -20005;

    x_site_incompatible       EXCEPTION;
    x_materiel_deja_attribue  EXCEPTION;
    x_mac_dupliquee           EXCEPTION;
    x_ip_dupliquee            EXCEPTION;
    x_attribution_invalide    EXCEPTION;

    PRAGMA EXCEPTION_INIT(x_site_incompatible, -20001);
    PRAGMA EXCEPTION_INIT(x_materiel_deja_attribue, -20002);
    PRAGMA EXCEPTION_INIT(x_mac_dupliquee, -20003);
    PRAGMA EXCEPTION_INIT(x_ip_dupliquee, -20004);
    PRAGMA EXCEPTION_INIT(x_attribution_invalide, -20005);

    PROCEDURE raise_site_incompatible(p_message IN VARCHAR2 DEFAULT NULL);
    PROCEDURE raise_materiel_deja_attribue(p_message IN VARCHAR2 DEFAULT NULL);
    PROCEDURE raise_mac_dupliquee(p_message IN VARCHAR2 DEFAULT NULL);
    PROCEDURE raise_ip_dupliquee(p_message IN VARCHAR2 DEFAULT NULL);
    PROCEDURE raise_attribution_invalide(p_message IN VARCHAR2 DEFAULT NULL);
END PKG_EXCEPTIONS;
/

CREATE OR REPLACE PACKAGE BODY PKG_EXCEPTIONS AS
    PROCEDURE raise_error(
        p_code            IN PLS_INTEGER,
        p_default_message IN VARCHAR2,
        p_message         IN VARCHAR2
    ) IS
    BEGIN
        RAISE_APPLICATION_ERROR(p_code, COALESCE(p_message, p_default_message));
    END raise_error;

    PROCEDURE raise_site_incompatible(p_message IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        raise_error(
            c_site_incompatible,
            'Operation impossible : les objets appartiennent a des sites differents.',
            p_message
        );
    END raise_site_incompatible;

    PROCEDURE raise_materiel_deja_attribue(p_message IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        raise_error(
            c_materiel_deja_attribue,
            'Operation impossible : le materiel est deja attribue.',
            p_message
        );
    END raise_materiel_deja_attribue;

    PROCEDURE raise_mac_dupliquee(p_message IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        raise_error(
            c_mac_dupliquee,
            'Operation impossible : adresse MAC deja utilisee.',
            p_message
        );
    END raise_mac_dupliquee;

    PROCEDURE raise_ip_dupliquee(p_message IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        raise_error(
            c_ip_dupliquee,
            'Operation impossible : adresse IP deja utilisee.',
            p_message
        );
    END raise_ip_dupliquee;

    PROCEDURE raise_attribution_invalide(p_message IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        raise_error(
            c_attribution_invalide,
            'Operation impossible : attribution invalide.',
            p_message
        );
    END raise_attribution_invalide;
END PKG_EXCEPTIONS;
/

SHOW ERRORS PACKAGE PKG_EXCEPTIONS;
SHOW ERRORS PACKAGE BODY PKG_EXCEPTIONS;

EXIT;
