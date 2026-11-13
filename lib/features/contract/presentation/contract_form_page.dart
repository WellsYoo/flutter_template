import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:xjj_app_base/core/utils/logger.dart';
import 'package:xjj_app_base/shared/ui/ui.dart';

enum _ContractType {
  purchase('采购合同'),
  sale('销售合同'),
  service('服务合同');

  const _ContractType(this.label);

  final String label;
}

/// 新建合同：表单页的标准写法。输入 / 选择 / 日期 / 单选 / 开关 / 多行 + 底部提交。
///
/// 页面内的临时状态（表单字段）用 StatefulWidget 管理即可，不需要 Riverpod；
/// 提交时调用 repository，成功后返回上一页。
class ContractFormPage extends StatefulWidget {
  const ContractFormPage({super.key});

  @override
  State<ContractFormPage> createState() => _ContractFormPageState();
}

class _ContractFormPageState extends State<ContractFormPage> {
  String _name = '';
  String _phone = '';
  String _amount = '';
  _ContractType? _type;
  DateTime? _signDate;
  List<String> _tags = [];
  String _payment = '银行转账';
  bool _needInvoice = true;
  String _remark = '';

  static const _allTags = ['加急', '大客户', '续签', '框架协议'];

  Future<void> _pickTags() async {
    final v = await XSheet.multiSelect(title: '标签', options: _allTags, selected: _tags);
    if (v != null) setState(() => _tags = v);
  }

  /// 返回第一个错误，null 表示通过
  String? _validate() {
    return Validators.required(_name, '客户名称') ??
        Validators.phone(_phone) ??
        Validators.required(_amount, '合同金额') ??
        // 输入限制拦不住只输了一个小数点的情况，转数字前再判断一次
        (double.tryParse(_amount) == null ? '合同金额格式不正确' : null) ??
        (_type == null ? '请选择合同类型' : null) ??
        (_signDate == null ? '请选择签订日期' : null);
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) return XToast.show(error);

    // 实际项目里换成 repository.submit(form)
    final form = {
      'name': _name,
      'phone': _phone,
      'amount': double.parse(_amount),
      'type': _type!.name,
      'signDate': Fmt.date(_signDate),
      'tags': _tags,
      'payment': _payment,
      'needInvoice': _needInvoice,
      'remark': _remark,
    };
    await XLoading.run(() => Future<void>.delayed(const Duration(seconds: 1)), message: '提交中');
    Log.d('提交表单 $form');
    XToast.success('提交成功');
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新建合同')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          XFormSection(
            title: '客户信息',
            children: [
              XFormItem.input(
                label: '客户名称',
                required: true,
                maxLength: 30,
                onChanged: (v) => _name = v,
              ),
              XFormItem.input(
                label: '手机号',
                required: true,
                keyboardType: TextInputType.phone,
                inputFormatters: InputFormats.phone,
                onChanged: (v) => _phone = v,
              ),
            ],
          ),
          XFormSection(
            title: '合同信息',
            children: [
              XFormItem.input(
                label: '合同金额',
                required: true,
                suffix: '元',
                help: '含税金额，最多两位小数',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [InputFormats.decimal(2)],
                onChanged: (v) => _amount = v,
              ),
              // picker / date 自带弹层，选完直接回调
              XFormItem.picker(
                label: '合同类型',
                required: true,
                options: _ContractType.values,
                labelOf: (t) => t.label,
                value: _type,
                onChanged: (v) => setState(() => _type = v),
              ),
              XFormItem.date(
                label: '签订日期',
                required: true,
                value: _signDate,
                onChanged: (v) => setState(() => _signDate = v),
              ),
              XFormItem.select(label: '标签', value: _tags.join('、'), onTap: _pickTags),
              XFormItem.radio(
                label: '付款方式',
                options: const ['银行转账', '承兑汇票', '现金'],
                value: _payment,
                onChanged: (v) => setState(() => _payment = v),
              ),
              XFormItem.switcher(
                label: '需要发票',
                value: _needInvoice,
                onChanged: (v) => setState(() => _needInvoice = v),
              ),
              XFormItem.text(label: '经办人', value: '张三'),
            ],
          ),
          XFormSection(
            children: [
              XFormItem.textarea(label: '备注', maxLength: 200, onChanged: (v) => _remark = v),
            ],
          ),
        ],
      ),
      bottomNavigationBar: XBottomBar(
        children: [
          XButton.outline('保存草稿', onPressed: () => XToast.show('已保存草稿')),
          XButton.primary('提交', onPressed: _submit),
        ],
      ),
    );
  }
}
